jobs = Delayed::Job.where("handler LIKE '%Html5VideoPlugin::CreateVideo%'")

file_ids = {}

jobs.each do |job|
  file_id = job.handler.match(/file_id: ([0-9]*)/)[1]
  file_type = job.handler.match(/file_type: ([a-zA-Z]*)/)[1]
  full_filename = job.handler.match(/full_filename: \"([^\"]*)\"/)[1]
  file_ids[file_id] = {}
  file_ids[file_id]['file_type'] = file_type
  file_ids[file_id]['full_filename'] = full_filename
end

file_ids.each do |file_id, hash|
  job = Html5VideoPlugin::EnqueueVideoConversionJob.new
  job.file_id = file_id
  job.file_type = hash['file_type']
  job.full_filename = hash['full_filename']
  Delayed::Job.enqueue job, priority: 10
end
