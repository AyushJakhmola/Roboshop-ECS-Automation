locals {
    cart_image = "421320058418.dkr.ecr.us-west-2.amazonaws.com/robotshop:rs-cart"
    user_image = "421320058418.dkr.ecr.us-west-2.amazonaws.com/robotshop:rs-user"
    catalogue_image = "421320058418.dkr.ecr.us-west-2.amazonaws.com/robotshop:rs-catalogue"
    shipping_image = "421320058418.dkr.ecr.us-west-2.amazonaws.com/robotshop:rs-shipping"
    payment_image = "421320058418.dkr.ecr.us-west-2.amazonaws.com/robotshop:rs-payment"
    rating_image = "421320058418.dkr.ecr.us-west-2.amazonaws.com/robotshop:rs-ratings"
    dispatch_image = "421320058418.dkr.ecr.us-west-2.amazonaws.com/robotshop:rs-dispatch"
    web_image = "309017165673.dkr.ecr.us-east-1.amazonaws.com/web"

# cart conf
catalogue_host = "catalogue.robotshop"
redis_host = "redis.robotshoptf"
cart_server_port = 8080

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

}