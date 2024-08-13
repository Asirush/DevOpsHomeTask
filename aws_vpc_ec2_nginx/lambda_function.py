import boto3

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    elbv2 = boto3.client('elbv2')

    filters = [
        {'Name': 'tag:ClusterID', 'Values': ['101']},
        {'Name': 'tag:RoleID', 'Values': ['1']},
        {'Name': 'instance-state-name', 'Values': ['running']}
    ]
    
    instances = ec2.describe_instances(Filters=filters)
    instance_ids = [i['InstanceId'] for r in instances['Reservations'] for i in r['Instances']]

    response = elbv2.describe_target_groups()
    target_group_arn = next(tg['TargetGroupArn'] for tg in response['TargetGroups'] if tg['TargetGroupName'] == 'devops-hometask-nlb-tg')

    targets = [{"Id": id} for id in instance_ids]

    if targets:
        elbv2.register_targets(TargetGroupArn=target_group_arn, Targets=targets)
    else:
        elbv2.deregister_targets(TargetGroupArn=target_group_arn, Targets=targets)
