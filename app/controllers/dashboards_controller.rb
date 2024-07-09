class DashboardsController < ApplicationController
  def show
    period = params
      .fetch(:period, { year: Date.current.year, week: Date.current.cweek })
      .permit(:year, :week, :month, :quarter)
      .to_h
      .reverse_merge(year: 2024)
      .transform_values(&:to_i)
    time_range = case period
    in year:, week:
      date = Date.commercial(year, week)
      start = date.at_beginning_of_week
      stop = date.at_end_of_week
      start..stop
    in year:, month:
      date = Date.new(year, month)
      start = date.at_beginning_of_month
      stop = date.at_end_of_month
      start..stop
    in year:, quarter:
      date = Date.new(year, quarter * 3)
      start = date.at_beginning_of_quarter
      stop = date.at_end_of_quarter
      start..stop
    end
    pp time_range
    @user_sessions_chart_data = [
      {
        name: "Total Sessions",
        data: entire_period(time_range, sessions_per_day(time_range).count)
      },
      {
        name: "Unique Users",
        data: entire_period(time_range, sessions_per_day(time_range).distinct.count(:user_id))
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

    def entire_period(time_range, data)
      time_range.index_with(0).merge(data)
    end
end
