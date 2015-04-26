# # encoding: utf-8
# CarrierWave.configure do |config|
#   config.storage = :aliyun
#   config.aliyun_access_id = "s9re4BTWed2H4etp"
#   config.aliyun_access_key = 'dumRYgPup5HjBRB58II6Con9mGTJ2o'
#   # 你需要在 Aliyum OSS 上面提前创建一个 Bucket
#   if Rails.env.production?
#     config.aliyun_bucket = "blsm-public"
#     config.aliyun_host = "image.yepcolor.com"
#   end
#   if Rails.env.development?
#     config.aliyun_bucket = "test8811609"
#     config.aliyun_host = "test8811609.oss.aliyuncs.com"
#   end
#   # 是否使用内部连接，true - 使用 Aliyun 局域网的方式访问  false - 外部网络访问
#   config.aliyun_internal = false
#   # 使用自定义域名，设定此项，carrierwave 返回的 URL 将会用自定义域名
#   # 自定于域名请 CNAME 到 you_bucket_name.oss.aliyuncs.com (you_bucket_name 是你的 bucket 的名称)
# end
