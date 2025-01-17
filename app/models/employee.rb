class Employee < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  after_validation :geocode
  has_many :employee_tasks, dependent: :destroy
  has_many :tasks, through: :employee_tasks
  geocoded_by :address
  validates :name, :address, :document, presence: true

  after_create do
    broadcast_prepend_to "employees"
  end
  after_update do
    broadcast_update_to "employees"
    self.tasks.each do |task|
      broadcast_update_to "tasks", partial: "tasks/task", locals: {task: task}, target: "task_#{task.id}"
    end
  end

  after_destroy_commit do
    broadcast_remove_to "employees"
  end
end
