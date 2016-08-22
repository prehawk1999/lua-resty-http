# vim:set ft= ts=4 sw=4 et:

use Test::Nginx::Socket;
use Cwd qw(cwd);

plan tests => repeat_each() * (blocks() * 4)    ;

my $pwd = cwd();

our $HttpConfig = qq{
    lua_package_path "$pwd/lib/?.lua;;";
    error_log logs/error.log debug;
};

$ENV{TEST_NGINX_RESOLVER} = '8.8.8.8';

no_long_string();
#no_diff();

run_tests();


__DATA__
=== TEST 1 parse_uri test: domain should be parse correctly.
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        content_by_lua_block {
            local http = require "resty.http"

            local url = 'https://p.skimresources.com?provider_id=236e5777-945a-4f00-8159-ccdacd6e0c04&skim_mapping=true&provider_dc=pao'
            local m = http:parse_uri(url)
            ngx.say(m[2])
        }
    }
--- request
GET /a
--- response_body
p.skimresources.com
--- no_error_log
[error]
[warn]

=== TEST 2 parse_uri test: domain should be parse correctly.
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        content_by_lua_block {
            local http = require "resty.http"

            local url = 'https://www.baidu.com:80?proc=38875'
            local m = http:parse_uri(url)
            ngx.say(m[2])
        }
    }
--- request
GET /a
--- response_body
www.baidu.com
--- no_error_log
[error]
[warn]

=== TEST 3 parse_uri test: domain should be parse correctly.
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        content_by_lua_block {
            local http = require "resty.http"

            local url = 'http://www.sina.com.cn#38'
            local m = http:parse_uri(url)
            ngx.say(m[2])
        }
    }
--- request
GET /a
--- response_body
www.sina.com.cn
--- no_error_log
[error]
[warn]

=== TEST 4 parse_uri test: domain should be parse correctly.
--- http_config eval: $::HttpConfig
--- config
    location = /a {
        content_by_lua_block {
            local http = require "resty.http"

            local url = 'http://www.tencent.com\\fh'
            local m = http:parse_uri(url)
            ngx.say(m[2])
        }
    }
--- request
GET /a
--- response_body
www.tencent.com
--- no_error_log
[error]
[warn]
