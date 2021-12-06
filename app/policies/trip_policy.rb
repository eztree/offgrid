class TripPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end

  def show?
    record.user == user
  end

  def create?
    record.user == user
  end

  def cancel?
    record.user == user
  end
end
