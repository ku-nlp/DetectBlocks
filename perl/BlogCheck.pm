package BlogCheck;

# $Id$

use strict;
use utf8;
use HTML::TreeBuilder;
use Data::Dumper;
use Dumpvalue;

use Encode;
use Encode::Guess;

# ブログのURL
our $BLOG_URL = 'blog|ameblo|diary';

# ブログ特有の語
our $BLOG_STRING = 'トラックバック|コメント|comment|プロフィール|trackback|ブログ|blog|投稿者|posted by';

# ブログと判定するブログ特有の語の最小数
our $BLOG_STRING_NUM = 10;

# ブログでないと判定する特有語の最大数
our $NBLOG_STRING_NUM = 3;

# ブログなら 1 にする
my $BLOG_FLAG = 0;

# ブログの発信者後のワード
our $BLOG_SENDER = '(posted by (.+?) at |^(.+?) at \d|author(.+?)$|commented by (.+?)$|(.+?)日記$|投稿者(.+?)$)';


sub new {
    my ($this, $DetectBlocks) = @_;
    my $this = {
	DetectBlocks => $DetectBlocks
	};

    bless $this;
}

sub blog_check {
    my ($this) = @_;

    my $body = $this->{DetectBlocks}->{tree}->find('body');

    my $url = $this->{DetectBlocks}->{url};
    $this->blog_url($url);

    # ブログ特有の語の個数でブログかどうか判断
    $this->check_blog_string($body);
    $this->blog_sender($body);
}

# URLからブログかどうか判断する
sub blog_url{
    my ($this, $url) = @_;

    if (defined $url) {
	$this->{url} = $url;
	if ($url =~ /$BLOG_URL/) {
	    $BLOG_FLAG = 1;
	}
    }
}


# ブログ特有の語の頻度でブログかどうか判断する
sub check_blog_string {
    my ($this, $body) = @_;
    my @alltext = $this->{DetectBlocks}->get_text($body);
    my $blog_string_num = 0;
    foreach my $k (@alltext) {
	if (my $matches = ($k =~ s/$BLOG_STRING/\1/ig)) {
	    $blog_string_num += $matches;
	}
    }

#    print $blog_string_num . "\n";
    if ($blog_string_num >= $BLOG_STRING_NUM ) {
	$BLOG_FLAG = 1;	    
    }
    if ($blog_string_num <= $NBLOG_STRING_NUM ) {
	$BLOG_FLAG = 0;
    }
}

# ブログかどうか判断して結果を出力
sub print_blog {
    my ($this) = @_;

    if ($BLOG_FLAG eq 1) {
	print "blog\n";
    } else {
	print "not blog\n";
    }
}

# 発信者候補を獲得して出力
sub blog_sender {
    my ($this, $body) = @_;
    
    my @texts = $this->{DetectBlocks}->get_text($body);

    if ($BLOG_FLAG eq 1) {
	foreach my $text(@texts){
	    if ($text =~ /$BLOG_SENDER/i) {
		print "$1" . "\n";
	    }
	}
    }
}
1;
