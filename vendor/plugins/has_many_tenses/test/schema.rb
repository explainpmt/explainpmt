ActiveRecord::Schema.define(:version => 0) do
  create_table :posts, :force => true do |t|
    t.string        :title
    t.text          :body
    t.timestamps
  end
  
  create_table :comments, :force => true do |t|
    t.references        :post
    t.timestamps
  end
end