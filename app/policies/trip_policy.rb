class TripPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end

  def show?
    record.user == user
  end

  def cancel?
    record.user == user
  end

  def update?
    record.user == user
  end

  def checklist_mobile?
    record.user == user
  end
end
