# townclock-ping-timercheck

Ping a TimerCheck.io URL every time TownClock.io chimes

TownClock.io should be chiming every 15 minutes, in us-east-1 and
us-west-2, around the clock, forever. A TownClock.io chime is a
message sent to a public SNS topic, and is broadcast to anybody who
subscribes their AWS Lambda function, SQS queue, or email address.

This project creates an AWS Lambda function and subscribes it to the
TownClock.io SNS Topic. Every time it is run, it resets the a
countdown timer on a TimerCheck.io timer to just a bit over 15 minutes.

I subscribe a StatusCake monitor to the TimerCheck.io timer URL. As
long as the timer does not expire, StatusCake considers the service to
be "up".

If TownClock.io were to miss a chime, then this AWS Lambda function
would not get called, the TimerCheck.io timer would expire, and
TimerCheck.io would return an error status to StatusCake. StatusCake
would consider the service to be "down" and would send me an alert.

See also:

- http://TownClock.io

- https://TimerCheck.io

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
