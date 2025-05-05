# ECS configuration for running MediaWiki

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  tags = {
    Name        = "${var.project_name}-cluster"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "mediawiki_logs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-logs"
    Environment = var.environment
  }
}

resource "aws_ecs_task_definition" "mediawiki" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  #  TODO: configure images volume
  # volume {
  #   name = "wiki-images"
  # }
  volume {
    name = "mediawiki-settings"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.mediawiki_settings.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.mediawiki_settings.id
        iam             = "ENABLED"
      }
    }
  }

  container_definitions = jsonencode([{
    name      = "mediawiki"
    image     = var.mediawiki_image
    essential = true

    portMappings = [
      {
        containerPort = 80
        hostPort      = 80
        protocol      = "tcp"
      }
    ]

    mountPoints = [
      {
        containerPath = "/var/www/html/settings" # Mount point inside container
        sourceVolume  = "mediawiki-settings"
        readOnly      = false
      }
      # {
      #   containerPath = "/var/www/html/imagesLink"
      # }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.mediawiki_logs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
    environment = [
      {
        name  = "MYSQL_HOST"
        value = aws_db_instance.wiki_db.address
      },
      {
        name  = "MYSQL_DATABASE"
        value = var.db_name
      },
      {
        name  = "MYSQL_USER"
        value = var.db_username
      },
      {
        name  = "MYSQL_PASSWORD"
        value = var.db_password
      },
      {
        name  = "S3_CONFIG_BUCKET"
        value = aws_s3_bucket.wikiuploads.bucket
      },
      {
        name  = "S3_CONFIG_FILE"
        value = var.config_file
      },
      {
        name  = "S3_LOGO_FILE"
        value = var.logo_file
      },
      {
        name  = "AWS_S3_REGION"
        value = var.aws_region
      },
      {
        name  = "MEDIAWIKI_SERVER_URL"
        value = "http://${aws_lb.main.dns_name}"
      }
    ]
  }])
}

resource "aws_ecs_service" "mediawiki" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.mediawiki.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.mediawiki.arn
    container_name   = "mediawiki"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.http]

  tags = {
    Name        = "${var.project_name}-cluster"
    Environment = var.environment
  }
}
