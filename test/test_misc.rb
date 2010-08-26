
if respond_to?(:require_relative, true)
  require_relative 'common'
else
  require File.dirname(__FILE__) + '/common'
end

describe RestGraph do
  after do
    reset_webmock
    RR.verify
  end

  it 'would build correct headers' do
    rg = RestGraph.new(:accept => 'text/html',
                       :lang   => 'zh-tw')
    rg.send(:build_headers).should == {'Accept'          => 'text/html',
                                       'Accept-Language' => 'zh-tw'}
  end

  it 'would build empty query string' do
    RestGraph.new.send(:build_query_string).should == ''
  end

  it 'would create access_token in query string' do
    RestGraph.new(:access_token => 'token').send(:build_query_string).
      should == '?access_token=token'
  end

  it 'would build correct query string' do
    TestHelper.normalize_query(
    RestGraph.new(:access_token => 'token').send(:build_query_string,
                                                 :message => 'hi!!')).
      should == '?access_token=token&message=hi%21%21'

    TestHelper.normalize_query(
    RestGraph.new.send(:build_query_string, :message => 'hi!!',
                                            :subject => '(&oh&)')).
      should == '?message=hi%21%21&subject=%28%26oh%26%29'
  end

  it 'would auto decode json' do
    RestGraph.new(:auto_decode => true).send(:post_request, '[]').
      should == []
  end

  it 'would not auto decode json' do
    RestGraph.new(:auto_decode => false).send(:post_request, '[]').
      should == '[]'
  end
end
