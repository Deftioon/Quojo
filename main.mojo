import quojo as qj

fn main() raises:
    var spider1 = qj.ZSpider(0.5, 2);
    var spider2 = qj.ZSpider(0.3, 2);
    var spider = spider1 + spider2;
    spider.print();