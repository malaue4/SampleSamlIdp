# Optionally override some pagy default with your own in the pagy initializer
Pagy::DEFAULT[:items] = 25 # items per page
Pagy::DEFAULT[:size]  = 9  # nav bar links

# Better user experience handled automatically
require "pagy/extras/overflow"
Pagy::DEFAULT[:overflow] = :last_page

require "pagy/extras/bootstrap"
