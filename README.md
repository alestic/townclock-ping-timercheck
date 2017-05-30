# townclock-ping-timercheck

Ping a TimerCheck.io URL every time the TownClock.io chimes

This is used to send out an alert if and when the TownClock.io does
not chime every 15 minutes. This resets the TimerCheck.io timer, and
you configure a StatusCake or other monitoring service to alert if the
TimerCheck.io timer URL returns non-success.

See also:

- http://TimerCheck.io

- http://TownClock.io

This software uses AWS Lambda subscribed to an SNS Topic. It deploys
using AWS SAM (Serverless Application Model) which generates AWS
CloudFormation.

The following commands work on Ubuntu 17.04 Zesty:

Set up buckets:

    for region in us-east-1 us-west-2; do
      aws s3 mb --region "$region" s3://YOURBUCKET-$region
    done

Deploy to AWS account:

    make \
      REGION=us-east-1 \
      PACKAGE_BUCKET=YOURBUCKET-us-east-1 \
      TOPIC_ARN=arn:aws:sns:us-east-1:522480313337:unreliable-town-clock-topic-178F1OQACHTYF \
      TIMER_URL=https://timercheck.io/YOURTIMER-us-east-1/960 \
      deploy

    make \
      REGION=us-west-2 \
      PACKAGE_BUCKET=YOURBUCKET-us-west-2 \
      TOPIC_ARN=arn:aws:sns:us-west-2:522480313337:unreliable-town-clock-topic-N4N94CWNOMTH \
      TIMER_URL=https://timercheck.io/YOURTIMER-us-west-2/960 \
      deploy
