pwd  = File.dirname(File.expand_path(__FILE__))

require 'rubygems'
require pwd + '/db_connection.rb'

class ContentSource < ActiveRecord::Base
  set_table_name :ContentSources;
end

class CrawlerContent < ActiveRecord::Base
  belongs_to :content_source
end

class ArticleWriter < ActiveRecord::Base
  has_and_belongs_to_many :newspapers
end

class Newspaper < ActiveRecord::Base
  has_and_belongs_to_many :article_writers
end

class Content < ActiveRecord::Base
  set_table_name :Content
end

class DocumentFrequency < ActiveRecord::Base
end

class DocTermFrequency < ActiveRecord::Base
end

