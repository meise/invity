# encoding: utf-8
=begin
Copyright Daniel Meißner <dm@3st.be>, 2011

This file is part of Invity to send email notifications of upcoming Freifunk events.

This script is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This Script is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Invity. If not, see <http://www.gnu.org/licenses/>.
=end

module Vines

  module Log
  end
end

%w[
  active_support/core_ext
  net/smtp rainbow

  mechanize
  log4r

  invity/version
].each {|lib| require "#{lib}" }


