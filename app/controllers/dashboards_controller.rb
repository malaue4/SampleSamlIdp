class DashboardsController < ApplicationController
  def show
    time_range = (1.week.ago.beginning_of_day..)
    @user_sessions_chart_data = [
      {
        name: "Total Sessions",
        data: sessions_per_day(time_range).count
      },
      {
        name: "Unique Users",
        data: sessions_per_day(time_range).distinct.count(:user_id)
      },
    ]
    @user_sessions_chart_data_time_of_day = sessions_by_hour_of_day(time_range).count
  end

  def side_show
    @user_sessions_chart_data = UserSession
                                  .where(created_at: 1.week.ago.beginning_of_day..)
                                  .pluck(:user_id, :created_at)
                                  .group_by(&:first)
                                  .transform_values do |created_ats|
      created_ats.map(&:last).map(&:to_date).tally
    end.map do |user_id, data|
      { name: user_id, data: data }
    end
  end

  private

    def sessions_per_day(time_range)
      UserSession
        .where(created_at: time_range)
        .group_by_day(:created_at)
    end

    def sessions_by_hour_of_day(time_range)
      UserSession
        .where(created_at: time_range)
        .group_by_hour_of_day(:created_at)
    end
end
