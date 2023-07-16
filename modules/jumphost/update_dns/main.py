from os import environ
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


def add_record(zone_id, zone_name, hostname, instance_id, ttl: int):
    """Add the instance to DNS."""
    print(f"Adding instance {instance_id} as a hostname {hostname} to zone {zone_id}")
    print(f"{zone_name =}")
    public_ip = get_public_ip(instance_id)
    print(f"{public_ip = }")

    route53_client = boto3.client("route53")
    response = route53_client.list_resource_record_sets(
        HostedZoneId=zone_id,
        StartRecordType="A",
        StartRecordName=f"{hostname}.{zone_name}",
        MaxItems="1",
    )
    ip_set = {public_ip}
    for rr_set in response["ResourceRecordSets"]:
        for rr in rr_set["ResourceRecords"]:
            ip_set.add(rr["Value"])

    r_records = [{"Value": ip} for ip in list(ip_set)]
    route53_client.change_resource_record_sets(
        HostedZoneId=zone_id,
        ChangeBatch={
            "Changes": [
                {
                    "Action": "UPSERT",
                    "ResourceRecordSet": {
                        "Name": f"{hostname}.{zone_name}",
                        "Type": "A",
                        "ResourceRecords": r_records,
                        "TTL": ttl,
                    },
                }
            ]
        },
    )


def remove_record(zone_id, zone_name, hostname, instance_id, ttl: int):
    """Remove the instance from DNS."""
    print(f"Removing instance {instance_id} from zone {zone_id}")
    print(f"{zone_name =}")
    public_ip = get_public_ip(instance_id)
    print(f"{public_ip = }")

    route53_client = boto3.client("route53")
    response = route53_client.list_resource_record_sets(
        HostedZoneId=zone_id,
        StartRecordType="A",
        StartRecordName=f"{hostname}.{zone_name}",
        MaxItems="1",
    )
    ip_set = set()
    for rr_set in response["ResourceRecordSets"]:
        for rr in rr_set["ResourceRecords"]:
            ip = rr["Value"]
            if ip != public_ip:
                ip_set.add(rr["Value"])
    r_records = [{"Value": ip} for ip in list(ip_set)]
    if r_records:
        route53_client.change_resource_record_sets(
            HostedZoneId=zone_id,
            ChangeBatch={
                "Changes": [
                    {
                        "Action": "UPSERT",
                        "ResourceRecordSet": {
                            "Name": f"{hostname}.{zone_name}",
                            "Type": "A",
                            "ResourceRecords": r_records,
                            "TTL": ttl,
                        },
                    }
                ]
            },
        )
    else:
        route53_client.change_resource_record_sets(
            HostedZoneId=zone_id,
            ChangeBatch={
                "Changes": [
                    {
                        "Action": "DELETE",
                        "ResourceRecordSet": {
                            "Name": f"{hostname}.{zone_name}",
                            "Type": "A",
                            "ResourceRecords": [{"Value": public_ip}],
                            "TTL": ttl,
                        },
                    }
                ]
            },
        )


def get_public_ip(instance_id):
    """Get the instance's public IP address by its instance_id"""
    ec2_client = boto3.client("ec2")
    response = ec2_client.describe_instances(
        InstanceIds=[
            instance_id,
        ],
    )
    print(f"describe_instances({instance_id}):")
    print(response)
    return response["Reservations"][0]["Instances"][0]["PublicIpAddress"]


def lambda_handler(event, context):
    print(f"{event = }")

    lifecycle_transition = event["detail"]["LifecycleTransition"]
    print(f"{lifecycle_transition = }")

    try:
        if lifecycle_transition == "autoscaling:EC2_INSTANCE_TERMINATING":
            remove_record(
                environ["ROUTE53_ZONE_ID"],
                environ["ROUTE53_ZONE_NAME"],
                environ["ROUTE53_HOSTNAME"],
                event["detail"]["EC2InstanceId"],
                int(environ["ROUTE53_TTL"]),
            )
        elif lifecycle_transition == "autoscaling:EC2_INSTANCE_LAUNCHING":
            add_record(
                environ["ROUTE53_ZONE_ID"],
                environ["ROUTE53_ZONE_NAME"],
                environ["ROUTE53_HOSTNAME"],
                event["detail"]["EC2InstanceId"],
                int(environ["ROUTE53_TTL"]),
            )
    finally:
        complete_lifecycle_action(
            lifecyclehookname=event["detail"]["LifecycleHookName"],
            autoscalinggroupname=event["detail"]["AutoScalingGroupName"],
            lifecycleactiontoken=event["detail"]["LifecycleActionToken"],
            instanceid=event["detail"]["EC2InstanceId"],
        )
