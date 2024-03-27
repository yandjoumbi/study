import boto3


def lambda_handler(event, context):
    ec2_client = boto3.client('ec2')
    
    # Describe all Elastic IPs
    response = ec2_client.describe_addresses()
    for address in response['Addresses']:
        allocation_id = address['AllocationId']
        
        # Check if the Elastic IP is associated with an instance
        if 'InstanceId' not in address:
            # If not associated, release the Elastic IP
            ec2_client.release_address(AllocationId=allocation_id)
    
    return {
        'statusCode': 200,
        'body': 'Unused Elastic IPs deleted successfully'
    }
