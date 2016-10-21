require "nokogiri"

class Parser
  @doc = nil
  @conf = nil

  def initialize(html)
    @doc = Nokogiri::HTML.parse(html)
    @conf = Config.load
  end

  def get_entries
    entries = Array.new
    row_xpath = "//div[@id='trade-list']/table/tr[not(@class)]"
    @doc.xpath(row_xpath).each do |node|
      entry = Hash.new
      #Entry Title
      node.xpath("./td[contains(@class, 'list-title')]/p/a").each do |n|
        entry["title"] = n.text.strip
      end
      #Entry Author Name
      node.xpath("./td[contains(@class, 'list-name')]/a").each do |n|
        entry["author"] = n.text.strip
      end
      #Entry URL
      node.xpath("./td[contains(@class, 'list-title')]/p/a").each do |n|
        entry["url"] = "#{@conf['http']['base_url']}#{n.attribute("href").value}"
      end
      #Entry Unique ID
      node.xpath("./td[contains(@class, 'list-title')]/p/a").each do |n|
        params = URI.decode_www_form(n.attribute("href").value)
        entry["trade_id"] = params.assoc("ix").last
      end
      #Entry Type
      node.xpath("./td[contains(@class, 'list-icn')]/img").each do |n|
        src = n.attribute("src").value
        type = "販売" if src.match(/icn_trade_sell\.gif/)
        type = "買取" if src.match(/icn_trade_buy\.gif/)
        type = "交換" if src.match(/icn_trade_barter\.gif/)
        type = "その他" if src.match(/icn_trade_other\.gif/)
        entry["type"] = type
      end
      #Entry Created At
      node.xpath("./td[contains(@class, 'list-date')]").each do |n|
        entry["created"] = n.text.strip
      end
      entries.push(entry)
    end
    return entries
  end

  def xpath(xpath)
    return nil if @doc.nil?
    return @doc.xpath(xpath)
  end
end
