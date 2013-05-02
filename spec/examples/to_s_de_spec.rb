# encoding: utf-8

require File.dirname(__FILE__) + '/../spec_helper'

require 'debugger'

describe IceCube::Schedule, 'to_s' do
  before(:each) { I18n.locale = :de }

  it 'should have a useful base to_s representation for a secondly rule' do
    IceCube::Rule.secondly.to_s.should == 'Sekündlich'
    IceCube::Rule.secondly(2).to_s.should == 'Alle 2 Sekunden'
  end

  it 'should have a useful base to_s representation for a minutely rule' do
    IceCube::Rule.minutely.to_s.should == 'Minütlich'
    IceCube::Rule.minutely(2).to_s.should == 'Alle 2 Minuten'
  end

  it 'should have a useful base to_s representation for a hourly rule' do
    IceCube::Rule.hourly.to_s.should == 'Stündlich'
    IceCube::Rule.hourly(2).to_s.should == 'Alle 2 Stunden'
  end

  it 'should have a useful base to_s representation for a daily rule' do
    IceCube::Rule.daily.to_s.should == 'Täglich'
    IceCube::Rule.daily(2).to_s.should == 'Alle 2 Tage'
  end

  it 'should have a useful base to_s representation for a weekly rule' do
    IceCube::Rule.weekly.to_s.should == 'Wöchentlich'
    IceCube::Rule.weekly(2).to_s.should == 'Alle 2 Wochen'
  end

  it 'should have a useful base to_s representation for a monthly rule' do
    IceCube::Rule.monthly.to_s.should == 'Monatlich'
    IceCube::Rule.monthly(2).to_s.should == 'Alle 2 Monate'
  end

  it 'should have a useful base to_s representation for a yearly rule' do
    IceCube::Rule.yearly.to_s.should == 'Jährlich'
    IceCube::Rule.yearly(2).to_s.should == 'Alle 2 Jahre'
  end

  it 'should work with various sentence types properly' do
    IceCube::Rule.weekly.to_s.should == 'Wöchentlich'
    IceCube::Rule.weekly.day(:monday).to_s.should == 'Wöchentlich an Montagen'
    IceCube::Rule.weekly.day(:monday, :tuesday).to_s.should == 'Wöchentlich montags und dienstags'
    IceCube::Rule.weekly.day(:monday, :tuesday, :wednesday).to_s.should == 'Wöchentlich montags, dienstags, und mittwochs'
  end

  it 'should show saturday and sunday as weekends' do
    IceCube::Rule.weekly.day(:saturday, :sunday).to_s.should == 'Wöchentlich am Wochenende'
  end

  it 'should not show saturday and sunday as weekends when other days are present also' do
    IceCube::Rule.weekly.day(:sunday, :monday, :saturday).to_s.should ==
      'Wöchentlich sonntags, montags, and samstags'
  end

  it 'should reorganize days to be in order' do
    IceCube::Rule.weekly.day(:tuesday, :monday).to_s.should ==
      'Wöchentlich montags und dienstags'
  end

  it 'should show weekdays as such' do
    IceCube::Rule.weekly.day(
      :monday, :tuesday, :wednesday,
      :thursday, :friday
    ).to_s.should == 'Wöchentlich an Wochentagen'
  end

  it 'should not show weekdays as such when a weekend day is present' do
    IceCube::Rule.weekly.day(
      :sunday, :monday, :tuesday, :wednesday,
      :thursday, :friday
    ).to_s.should == 'Wöchentlich sonntags, montags, dienstags, mittwochs, donnerstags und freitags'
  end

  it 'should work with a single date' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_date Time.local(2010, 3, 20)
    schedule.to_s.should == "20. März 2010"
  end

  it 'should work with additional dates' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_date Time.local(2010, 3, 20)
    schedule.add_recurrence_date Time.local(2010, 3, 21)
    schedule.to_s.should == '20. März 2010, 21. März 2010'
  end

  it 'should order dates that are out of order' do
    schedule = IceCube::Schedule.new Time.now
    schedule.add_recurrence_date Time.local(2010, 3, 20)
    schedule.add_recurrence_date Time.local(2010, 3, 19)
    schedule.to_s.should == '19. März 2010, 20.März 2010'
  end

  it 'should remove duplicate rdates' do
    schedule = IceCube::Schedule.new Time.now
    schedule.add_recurrence_date Time.local(2010, 3, 20)
    schedule.add_recurrence_date Time.local(2010, 3, 20)
    schedule.to_s.should == '20. März 2010'
  end

  it 'should work with rules and dates' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_date Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly
    schedule.to_s.should == '20. März 2010, Wöchentlich'
  end

  it 'should work with rules and dates and exdates' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly
    schedule.add_recurrence_date Time.local(2010, 3, 20)
    schedule.add_exception_date Time.local(2010, 3, 20) # ignored
    schedule.add_exception_date Time.local(2010, 3, 21)
    schedule.to_s.should == 'Wöchentlich außer 20. März 2010, außer 21. März 2010'
  end

  it 'should work with a single rrule' do
    pending 'text?'
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly.day_of_week(:monday => [1])
    schedule.to_s.should == schedule.rrules[0].to_s
  end

  it 'should be able to say the last monday of the month' do
    rule_str = IceCube::Rule.monthly.day_of_week(:thursday => [-1]).to_s
    rule_str.should == 'Monatlich am letzten Donnerstag'
  end

  it 'should be able to say what months of the year something happens' do
    rule_str = IceCube::Rule.yearly.month_of_year(:june, :july).to_s
    rule_str.should == 'Jährlich im Juni und Juli'
  end

  it 'should be able to say the second to last monday of the month' do
    rule_str = IceCube::Rule.monthly.day_of_week(:thursday => [-2]).to_s
    rule_str.should == 'Monatlich am vorletzten Donnerstag'
  end

  it 'should be able to say the days of the month something happens' do
    rule_str = IceCube::Rule.monthly.day_of_month(1, 15, 30).to_s
    rule_str.should == 'Monatlich am  1, 15, und 30. Tag des Monats'
  end

  it 'should be able to say what day of the year something happens' do
    rule_str = IceCube::Rule.yearly.day_of_year(30).to_s
    rule_str.should == 'Jährlich am 30. Tag des Jahres'
  end

  it 'should be able to say what hour of the day something happens' do
    rule_str = IceCube::Rule.daily.hour_of_day(6, 12).to_s
    rule_str.should == 'Täglich zur 6. and 12. Stunde des Tages'
  end

  it 'should be able to say what minute of an hour something happens - with special suffix minutes' do
    rule_str = IceCube::Rule.hourly.minute_of_hour(10, 11, 12, 13, 14, 15).to_s
    rule_str.should == 'Stündlich zur 10, 11, 12, 13, 14. und 15. Minute der Stunde'
  end

  it 'should be able to say what seconds of the minute something happens' do
    rule_str = IceCube::Rule.minutely.second_of_minute(10, 11).to_s
    rule_str.should == 'Minütlich zur 10. und 11. Sekunde der Minute'
  end

  it 'should be able to reflect until dates' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.rrule IceCube::Rule.weekly.until(Time.local(2012, 2, 3))
    schedule.to_s.should == 'Wöchentlich bis 3. Februar 2012'
  end

  it 'should be able to reflect count' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.weekly.count(1)
    schedule.to_s.should == '1 mal Wöchentlich'
  end

  it 'should be able to reflect count (proper pluralization)' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.weekly.count(2)
    schedule.to_s.should == '2 mal Wöchentlich'
  end

  it 'should work when an end_time is set' do
    schedule = IceCube::Schedule.new(Time.local(2012, 8, 31), :end_time => Time.local(2012, 10, 31))
    schedule.add_recurrence_rule IceCube::Rule.daily.count(2)
    schedule.to_s.should == '2 mal täglich bis 31. Oktober 2012'
  end

end
