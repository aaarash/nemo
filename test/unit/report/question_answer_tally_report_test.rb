require 'test/test_helper'
require 'test/unit/report/report_test_helper'

class Report::QuestionAnswerTallyReportTest < ActiveSupport::TestCase
  include ReportTestHelper
  
  setup do
    prep_objects
  end

  test "Counts of Yes and No for all Yes-No questions" do
    # create several yes/no questions and responses for them
    create_opt_set(%w(Yes No))
    3.times{|i| create_question(:code => "yn#{i}", :name_eng => "Yes No Question #{i+1}", :type => "select_one")}
    1.times{create_response(:answers => {:yn0 => "Yes", :yn1 => "Yes", :yn2 => "Yes"})}
    2.times{create_response(:answers => {:yn0 => "Yes", :yn1 => "Yes", :yn2 => "No"})}
    3.times{create_response(:answers => {:yn0 => "Yes", :yn1 => "No", :yn2 => "Yes"})}
    4.times{create_response(:answers => {:yn0 => "No", :yn1 => "Yes", :yn2 => "Yes"})}
    
    # create report with question label 'code'
    report = create_report("QuestionAnswerTally", :option_set => @option_sets[:yes_no])
    
    # test                   
    assert_report(report, %w(     Yes No TTL ),
                          %w( yn0   6  4  10 ),
                          %w( yn1   7  3  10 ),
                          %w( yn2   8  2  10 ),
                          %w( TTL  21  9  30 ))
  end
  
  test "Counts of Yes and No for specific questions" do
    # create several questions and responses for them
    create_opt_set(%w(Yes No))
    create_opt_set(%w(High Low))
    2.times{|i| create_question(:code => "yn#{i}", :name_eng => "Yes No Question #{i+1}", :type => "select_one", :option_set => @option_sets[:yes_no])}
    2.times{|i| create_question(:code => "hl#{i}", :name_eng => "High Low Question #{i+1}", :type => "select_one", :option_set => @option_sets[:high_low])}
    1.times{create_response(:answers => {:yn0 => "Yes", :yn1 => "Yes", :hl0 => "High", :hl1 => "High"})}
    2.times{create_response(:answers => {:yn0 => "Yes", :yn1 => "Yes", :hl0 => "Low", :hl1 => "Low"})}
    3.times{create_response(:answers => {:yn0 => "Yes", :yn1 => "No", :hl0 => "Low", :hl1 => "High"})}
    4.times{create_response(:answers => {:yn0 => "No", :yn1 => "Yes", :hl0 => "High", :hl1 => "Low"})}
    
    # create report naming only three questions
    report = create_report("QuestionAnswerTally", 
      :calculations => [:yn0, :yn1, :hl1].collect{|code| Report::IdentityCalculation.new(:arg1 => @questions[code])}
    )
    
    # test                   
    assert_report(report, %w(     High Low Yes No TTL ),
                          %w( hl1    4   6   _  _  10 ),
                          %w( yn0    _   _   6  4  10 ),
                          %w( yn1    _   _   7  3  10 ),
                          %w( TTL    4   6  13  7  30 ))
  end
  
  test "Counts of Yes and No for empty result" do
    # create several option sets but only responses for the last one
    create_opt_set(%w(Yes No))
    create_opt_set(%w(Low High))
    create_question(:code => "yn", :type => "select_one", :option_set => @option_sets[:yes_no])
    create_question(:code => "lh", :type => "select_one", :option_set => @option_sets[:low_high])
    4.times{create_response(:answers => {:lh => "Low"})}
    
    # create report
    report = create_report("QuestionAnswerTally", :option_set => @option_sets[:yes_no])
    
    # ensure no data
    assert_report(report, nil)
  end

  test "Counts of Yes and No and Zero/Nonzero" do
    # create several questions and responses for them
    create_opt_set(%w(Yes No))
    2.times{|i| create_question(:code => "yn#{i}", :name_eng => "Yes No Question #{i+1}", :type => "select_one", :option_set => @option_sets[:yes_no])}
    create_question(:code => "int", :type => "integer")
    create_question(:code => "dec", :type => "decimal")
    1.times{create_response(:answers => {:yn0 => "Yes", :yn1 => "Yes", :int => 3, :dec => 1.5})}
    2.times{create_response(:answers => {:yn0 => "Yes", :yn1 => "Yes", :int => 2, :dec => 0})}
    3.times{create_response(:answers => {:yn0 => "Yes", :yn1 => "No", :int => 0, :dec => 4.5})}
    4.times{create_response(:answers => {:yn0 => "No", :yn1 => "Yes", :int => 0, :dec => 0})}

    # create report naming only three questions
    report = create_report("QuestionAnswerTally", :calculations => [
      Report::IdentityCalculation.new(:arg1 => @questions[:yn0]),
      Report::ZeroNonzeroCalculation.new(:arg1 => @questions[:int]),
      Report::ZeroNonzeroCalculation.new(:arg1 => @questions[:dec])
    ])
    
    # test                   
    assert_report(report, %w(     Zero Non-Zero Yes No TTL ),
                          %w( dec    6        4   _  _  10 ),
                          %w( int    7        3   _  _  10 ),
                          %w( yn0    _        _   6  4  10 ),
                          %w( TTL   13        7   6  4  30 ))
   end
   
  # try it with multiselect
  # try it with filter
end