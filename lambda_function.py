import json
import logging
import os

logger = logging.getLogger()
logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


def lambda_handler(event, context):
    logger.info("Event received: %s", json.dumps(event))

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Hello from Lambda"})
    }
