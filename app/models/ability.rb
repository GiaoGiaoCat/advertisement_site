class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)

    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    alias_action :create, :read, :update, :destroy, :to => :crud
    alias_action :create, :read, :update, :to => :cru
    alias_action :create, :read, :to => :cr
    alias_action :read, :update, :to => :ru

    # can :manage, Article  # user can perform any action on the article
    # can :read, :all       # user can read any object
    # can :manage, :all     # user can perform any action on any object
    # can :crud, :all     # user can perform any action on any object
    if user.role?(:admin)
      can :manage, :all
    elsif user.role?(:channel_manager)
      can :manage, [AdvContent, Payment, Rule, AdvDetail, AccountBillInfo, User]
      can :cru, Channel
      can :cr, AccountBill
      can :create, [Application, Profile, Payment]
      can :u, Channel, :manager_id => user.id
      can :read, Application
    elsif user.role?(:developer)
      can :create, [Application, Profile, Payment]
      can :ru, Application, :user_id => user.id
      can :read, Profile, :user_id => user.id
      can :read, Payment, :user_id => user.id
    elsif user.role?(:spreader)
      can :create, [Profile, Payment]
      can :read, Profile, :user_id => user.id
      can :read, Payment, :user_id => user.id
    elsif user.role?(:secretary)
      can :manage, [Platform, PlatformBalanceio, PlatformAccount, AdvContent]
    elsif user.role?(:finance)
      can :ru, [AccountBill]
    end

    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
