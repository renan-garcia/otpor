json.status do
  json.name @status[:name]
  json.code @status[:code]
  json.type @status[:type]
end

json.data do
  json.partial! @data_partial if @data_partial.present?
end

json.errors @errors
json.notes @notes
json.meta @meta
json.exception_log @exception_log
