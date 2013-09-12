# encoding: utf-8

require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube::Schedule, 'to_s' do
  before(:each) { I18n.locale = :pt }

  it 'should have a useful base to_s representation for a secondly rule' do
    IceCube::Rule.secondly.to_s.should == 'cada segundo'
    IceCube::Rule.secondly(2).to_s.should == 'a cada 2 segundos'
  end

  it 'should have a useful base to_s representation for a minutely rule' do
    IceCube::Rule.minutely.to_s.should == 'cada minuta'
    IceCube::Rule.minutely(2).to_s.should == 'a cada 2 minutas'
  end

  it 'should have a useful base to_s representation for a hourly rule' do
    IceCube::Rule.hourly.to_s.should == 'cada hora'
    IceCube::Rule.hourly(2).to_s.should == 'a cada 2 horas'
  end

  it 'should have a useful base to_s representation for a daily rule' do
    IceCube::Rule.daily.to_s.should == 'cada dia'
    IceCube::Rule.daily(2).to_s.should == 'a cada 2 dias'
  end

  it 'should have a useful base to_s representation for a weekly rule' do
    IceCube::Rule.weekly.to_s.should == 'cada semana'
    IceCube::Rule.weekly(2).to_s.should == 'a cada 2 semanas'
  end

  it 'should have a useful base to_s representation for a monthly rule' do
    IceCube::Rule.monthly.to_s.should == 'cada mês'
    IceCube::Rule.monthly(2).to_s.should == 'a cada 2 mêses'
  end

  it 'should have a useful base to_s representation for a yearly rule' do
    IceCube::Rule.yearly.to_s.should == 'cada ano'
    IceCube::Rule.yearly(2).to_s.should == 'a cada 2 anos'
  end

  it 'should work with various sentence types properly' do
    IceCube::Rule.weekly.to_s.should == 'cada semana'
    IceCube::Rule.weekly.day(:monday).to_s.should == 'cada semana na Segunda'
    IceCube::Rule.weekly.day(:monday, :tuesday).to_s.should == 'cada semana na Segunda e na Terça'
    IceCube::Rule.weekly.day(:monday, :tuesday, :wednesday).to_s.should == 'cada semana na Segunda, na Terça e na Quarta'
  end

  it 'should show saturday and sunday as weekends' do
    IceCube::Rule.weekly.day(:saturday, :sunday).to_s.should == 'cada semana no fim da semana'
  end

  it 'should not show saturday and sunday as weekends when other days are present also' do
    IceCube::Rule.weekly.day(:sunday, :monday, :saturday).to_s.should ==
      'cada semana no Domingo, na Segunda e no Sábado'
  end

  it 'should reorganize days to be in order' do
    IceCube::Rule.weekly.day(:tuesday, :monday).to_s.should ==
      'cada semana na Segunda e na Terça'
  end

  it 'should show weekdays as such' do
    IceCube::Rule.weekly.day(
      :monday, :tuesday, :wednesday,
      :thursday, :friday
    ).to_s.should == 'cada semana em dia de útil'
  end

  it 'should not show weekdays as such when a weekend day is present' do
    IceCube::Rule.weekly.day(
      :sunday, :monday, :tuesday, :wednesday,
      :thursday, :friday
    ).to_s.should == 'cada semana no Domingo, na Segunda, na Terça, na Quarta, na Quinta e na Sexta'
  end

  it 'should work with a single date' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.to_s.should == "20. Março 2010"
  end

  it 'should work with additional dates' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 21)
    schedule.to_s.should == '20. Março 2010, 21. Março 2010'
  end

  it 'should order dates that are out of order' do
    schedule = IceCube::Schedule.new Time.now
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 19)
    schedule.to_s.should == '19. Março 2010, 20. Março 2010'
  end

  it 'should remove duplicate rdates' do
    schedule = IceCube::Schedule.new Time.now
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.to_s.should == '20. Março 2010'
  end

  it 'should work with rules and dates' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly
    schedule.to_s.should == '20. Março 2010, cada semana'
  end

  it 'should work with rules and dates and exdates' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_exception_date Time.local(2010, 3, 20) # ignored
    schedule.add_exception_date Time.local(2010, 3, 21)
    schedule.to_s.should == 'cada semana, senão 20. Março 2010 e 21. Março 2010'
  end

  it 'should work with a single rrule' do
    pending 'remove dependency'
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly.day_of_week(:monday => [1])
    schedule.to_s.should == schedule.rrules[0].to_s
  end

  it 'should be able to say the last monday of the month' do
    rule_str = IceCube::Rule.monthly.day_of_week(:thursday => [-1]).to_s
    rule_str.should == 'cada mês na última Quinta'
  end

  it 'should be able to say what months of the year something happens' do
    rule_str = IceCube::Rule.yearly.month_of_year(:june, :july).to_s
    rule_str.should == 'cada ano no Junho e Julho'
  end

  it 'should be able to say the second to last monday of the month' do
    pending 'penultimo'
    rule_str = IceCube::Rule.monthly.day_of_week(:thursday => [-2]).to_s
    rule_str.should == 'cada mês onthly on the 2nd to last Thursday'
  end

  it 'should be able to say the days of the month something happens' do
    rule_str = IceCube::Rule.monthly.day_of_month(1, 15, 30).to_s
    rule_str.should == 'cada mês no 1o, 15o e 30o dia do mês'
  end

  it 'should be able to say what day of the year something happens' do
    rule_str = IceCube::Rule.yearly.day_of_year(30).to_s
    rule_str.should == 'cada ano no 30o dia do ano'
  end

  it 'should be able to say what hour of the day something happens' do
    rule_str = IceCube::Rule.daily.hour_of_day(6, 12).to_s
    rule_str.should == 'cada dia na 6a e 12a hora do dia'
  end

  it 'should be able to say what minute of an hour something happens - with special suffix minutes' do
    rule_str = IceCube::Rule.hourly.minute_of_hour(10, 11, 12, 13, 14, 15).to_s
    rule_str.should == 'cada hora na 10a, 11a, 12a, 13a, 14a e 15a minuta da hora'
  end

  it 'should be able to say what seconds of the minute something happens' do
    rule_str = IceCube::Rule.minutely.second_of_minute(10, 11).to_s
    rule_str.should == 'cada minuta no 10o e 11o segundo da minuta'
  end

  it 'should be able to reflect until dates' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.rrule IceCube::Rule.weekly.until(Time.local(2012, 2, 3))
    schedule.to_s.should == 'cada semana até 3. Fevereiro 2012'
  end

  it 'should be able to reflect count' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.weekly.count(1)
    schedule.to_s.should == 'cada semana 1a vês'
  end

  it 'should be able to reflect count (proper pluralization)' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.weekly.count(2)
    schedule.to_s.should == 'cada semana 2as vêses'
  end

  it 'should work when an end_time is set' do
    schedule = IceCube::Schedule.new(Time.local(2012, 8, 31), :end_time => Time.local(2012, 10, 31))
    schedule.add_recurrence_rule IceCube::Rule.daily.count(2)
    schedule.to_s.should == 'cada dia 2as vêses, até 31. Outubro 2012'
  end

end
