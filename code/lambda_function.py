#!/usr/bin/env python3.6
import sys
sys.path.insert(1, 'lib')
import os
import json
import logging
import requests
from requests.packages.urllib3.util.retry import Retry
from requests.adapters import HTTPAdapter

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Retry until AWS Lambda function times out
retries = Retry(total=None,
                status_forcelist=[500, 502, 503, 504])
session = requests.Session()
session.mount('http://', HTTPAdapter(max_retries=retries))
session.mount('https://', HTTPAdapter(max_retries=retries))

def lambda_handler(event, context):
    try:
        logger.info('event: {}'.format(json.dumps(event)))
        url = os.environ['url']
        response = session.get(url)
        logger.info('response: {}\n{}'.format(
            response.status_code, response.content.decode("utf-8")))
    except Exception as e:
        logger.error("Unexpected Error: {}".format(e))

if __name__ == "__main__":
    import sys
    logging.basicConfig(stream=sys.stderr)
    timer='townclock-ping-timercheck-demo'
    seconds='1200'
    os.environ['url'] = 'https://timercheck.io/'+timer+'/'+seconds
    lambda_handler({
      "source": "townclock.chime",
      "type": "chime",
      "version": "3.0",
      "timestamp": "2017-05-20 01:45 UTC",
      "year": "2017",
      "month": "05",
      "day": "20",
      "hour": "01",
      "minute": "45",
      "day_of_week": "Sat",
      "unique_id": "02976691-0e70-4dbd-8191-a2f26819e1f7",
      "region": "us-east-1",
      "sns_topic_arn": "arn:aws:sns:us-east-1:522480313337:unreliable-town-clock-topic-178F1OQACHTYF",
      "reference": "http://townclock.io",
      "support": "First Last <nobody@example.com>",
      "disclaimer": "UNRELIABLE SERVICE"
    }, None)
