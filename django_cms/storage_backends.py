from storages.backends.s3boto3 import S3Boto3Storage


class MediaStorage(S3Boto3Storage):
    location = 'public'
    file_overwrite = False
    default_acl = 'public-read'


class StaticStorage(S3Boto3Storage):
    location = 'static'
    file_overwrite = True
    default_acl = 'public-read'
