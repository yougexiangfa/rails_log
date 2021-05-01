module Email
  module Model::Template
    extend ActiveSupport::Concern

    included do
      attribute :honorific, :string
      attribute :body, :string
      attribute :order_prefix, :string
      attribute :position, :integer, index: true

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      has_one_attached :cover

      acts_as_list
    end



  end
end
