# ==============================================================================
# APPLICATION LOAD BALANCER
# ==============================================================================
# WHY: Distributes traffic across multiple EC2 instances
# BENEFITS: High availability, auto-healing, SSL termination
# ==============================================================================

resource "aws_lb" "main" {
  name               = "${var.app_name}-alb"
  internal           = false  # Internet-facing (public)
  load_balancer_type = "application"  # Layer 7 (HTTP/HTTPS)
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids  # Must be in public subnets
  
  # Enable deletion protection in production
  enable_deletion_protection = var.environment == "prod" ? true : false
  
  # Enable access logs for audit/debugging
  # access_logs {
  #   bucket  = var.log_bucket
  #   enabled = true
  # }
  
  tags = {
    Name = "${var.app_name}-alb"
  }
}

# ==============================================================================
# TARGET GROUP
# ==============================================================================
# WHY: Defines WHERE to send traffic (EC2 instances)
# HEALTH CHECK: ALB only sends traffic to healthy instances
# ==============================================================================

resource "aws_lb_target_group" "main" {
  name_prefix = "${substr(var.app_name, 0, 6)}-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  
  # Deregistration delay: Wait 30 seconds before removing instance
  # Allows in-flight requests to complete
  deregistration_delay = 30
  
  # ==============================================================================
  # HEALTH CHECK
  # ==============================================================================
  # WHY: ALB continuously checks if instances are healthy
  # UNHEALTHY INSTANCE: Removed from rotation, traffic goes to healthy ones
  # ==============================================================================
  
  health_check {
    enabled             = true
    healthy_threshold   = 2    # 2 consecutive successes = healthy
    unhealthy_threshold = 2    # 2 consecutive failures = unhealthy
    timeout             = 5    # Wait 5 seconds for response
    interval            = 30   # Check every 30 seconds
    path                = "/health"  # Endpoint to check
    protocol            = "HTTP"
    matcher             = "200"  # Success = HTTP 200
  }
  
  # Stickiness: Same user always goes to same instance
  # USE CASE: If you store session data in memory (not recommended)
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 3600  # 1 hour
    enabled         = false  # Disable for stateless apps
  }
  
  tags = {
    Name = "${var.app_name}-tg"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# ==============================================================================
# HTTPS LISTENER (443)
# ==============================================================================
# WHY: Handle HTTPS traffic (encrypted)
# REQUIRES: SSL certificate in AWS Certificate Manager
# ==============================================================================

resource "aws_lb_listener" "https" {
  count = var.ssl_certificate_arn != "" ? 1 : 0
  
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.ssl_certificate_arn
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# ==============================================================================
# HTTP LISTENER (80) - Redirect to HTTPS
# ==============================================================================
# WHY: Automatically upgrade HTTP to HTTPS
# SECURITY: Enforce encryption for all traffic
# ==============================================================================

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type = var.ssl_certificate_arn != "" ? "redirect" : "forward"
    
    # If SSL cert exists, redirect to HTTPS
    dynamic "redirect" {
      for_each = var.ssl_certificate_arn != "" ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"  # Permanent redirect
      }
    }
    
    # If no SSL cert (dev), forward directly
    target_group_arn = var.ssl_certificate_arn == "" ? aws_lb_target_group.main.arn : null
  }
}

