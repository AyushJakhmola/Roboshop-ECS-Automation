locals {
region = "us-east-1"
acc_id ="309017165673"
repo_name = "AyushJakhmola/robot-shop"
branch_name = "master"
repo_location = "https://github.com/AyushJakhmola/robot-shop.git"

# cart conf
catalogue_host = "catalogue.robotshop"
redis_host = "redis.robotshoptf"
cart_server_port = 8080
ecs_cluster_name = "ecs-robotshop-ec2"

# user conf
mongodb_url        = "mongodb://robo:asdfghjkl123@mongodb.robotshopecs/admin"
user_server_port = 8080

# catalogue conf
catalogue_server_port = 8080

# shipping conf
cart_endpoint        = "cart.${var.ecs_namespace}"
catalogue_url   = "catalogue.${var.ecs_namespace}"
db_host   = "mysql:host=mysql.${var.ecs_namespace};dbname=ratings;charset=utf8mb4" 

# payment conf
amqp_host        = "rabitmq.${var.ecs_namespace}"
payment_gateway = "https://paypal.com/"
shipping_host   = "shipping.${var.ecs_namespace}"
user_host = "user.${var.ecs_namespace}"
shop_payment_port = 8080

# rating conf
pdo_url = "mysql:host=mysql.${var.ecs_namespace};dbname=ratings;charset=utf8mb4"

# web conf
cart_host = "cart.${var.ecs_namespace}"
payment_host = "payment.${var.ecs_namespace}"
rating_host = "rating.${var.ecs_namespace}"

apps = ["mongo", "mysql", "cart", "user", "catalogue", "shipping", "payment", "ratings", "dispatch", "web"]

user_container_name = "user"
catalogue_container_name = "catalogue"
cart_container_name = "cart"
shipping_container_name = "shipping"
payment_container_name = "payment"
rating_container_name = "rating"
dispatch_container_name = "dispatch"
mongodb_container_name = "mongodb"
redis_container_name = "redis"
rabbitmq_container_name = "rabbitmq"
mysql_container_name = "mysql"
web_container_name = "web"

}