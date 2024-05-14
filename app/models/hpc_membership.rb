class HpcMembership < ApplicationRecord
  belongs_to :user
  belongs_to :hpc_group
end
