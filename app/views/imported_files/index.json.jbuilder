json.page @page
json.per_page @per_page
json.items_count @objects.count

json.items do
  json.array!(@objects, partial: '/imported_file', as: :imported_file)
end
