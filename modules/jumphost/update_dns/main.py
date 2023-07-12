import os
from pprint import pprint
import boto3


def complete_lifecycle_action(
    lifecyclehookname,
    autoscalinggroupname,
    lifecycleactiontoken,
    instanceid,
    lifecycleactionresult="CONTINUE",
):
    client = boto3.client("autoscaling")
    client.complete_lifecycle_action(
        LifecycleHookName=lifecyclehookname,
        AutoScalingGroupName=autoscalinggroupname,
        LifecycleActionToken=lifecycleactiontoken,
        LifecycleActionResult=lifecycleactionresult,
        InstanceId=instanceid,
    )


def add_record():
    """Add the instance to DNS."""
    pass


def remove_record():
    """Remove the instance from DNS."""
    pass


def lambda_handler(event, context):
    print("event:")
    pprint(event)

    print("context:")
    pprint(context)

    client = boto3.client("sts")
    response = client.get_caller_identity()
    print("sts response:")
    pprint(response)

    if event["detail"]["LifecycleTransition"] == "autoscaling:EC2_INSTANCE_TERMINATING":
        remove_record()
    elif event["detail"]["LifecycleTransition"] == "autoscaling:EC2_INSTANCE_LAUNCHING":
        add_record()

    complete_lifecycle_action(
        lifecyclehookname=event["detail"]["LifecycleHookName"],
        autoscalinggroupname=event["detail"]["AutoScalingGroupName"],
        lifecycleactiontoken=event["detail"]["LifecycleActionToken"],
        instanceid=event["detail"]["EC2InstanceId"],
    )
