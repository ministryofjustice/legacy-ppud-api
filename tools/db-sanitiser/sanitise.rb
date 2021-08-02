#!/usr/bin/env ruby
# frozen_string_literal: true

require 'faker'
require 'logger'
require 'securerandom'
require 'sequel'
require 'tiny_tds'

db_connection_params = {
  adapter: 'tinytds',
  host: ENV.fetch('host'),
  port: '1433',
  database: ENV.fetch('name'),
  user: ENV.fetch('username'),
  password: ENV.fetch('password')
}

DB = Sequel.connect(db_connection_params)
logger = Logger.new($stdout)
DB.loggers << logger

offenders = DB[:OFFENDER]

prison_number_set = offenders
                    .exclude(PRISON_NUMBER: 'DUPLICATE')
                    .exclude(PRISON_NUMBER: 'Not Applicable')
                    .exclude(PRISON_NUMBER: nil)
                    .select(:OFFENDER_ID)

prison_number_set.all.each do |row|
  prison_number = SecureRandom.alphanumeric(6).upcase

  offenders
    .where(OFFENDER_ID: row[:offender_id])
    .update(PRISON_NUMBER: prison_number)
end

dob_set = offenders
          .exclude(DOB: nil)
          .select(:OFFENDER_ID)

dob_set.all.each do |row|
  dob = Faker::Date.birthday(min_age: 17, max_age: 72)

  offenders
    .where(OFFENDER_ID: row[:offender_id])
    .update(DOB: dob)
end

cro_pnc_set = offenders
              .exclude(CRO_PNC: nil)
              .select(:OFFENDER_ID)

cro_pnc_set.all.each do |row|
  cro_pnc = "#{Faker::Number.number(digits: 7)}/#{Faker::Number.number(digits: 2)}#{('A'..'Z').to_a.sample(1).join}"

  offenders
    .where(OFFENDER_ID: row[:offender_id])
    .update(CRO_PNC: cro_pnc)
end

noms_id_set = offenders
              .exclude(NOMS_ID: nil)
              .select(:OFFENDER_ID)

noms_id_set.all.each do |row|
  noms_id = "#{Faker::Number.number(digits: 7)}#{('A'..'Z').to_a.sample(2).join}"

  offenders
    .where(OFFENDER_ID: row[:offender_id])
    .update(NOMS_ID: noms_id)
end

caseworkers = DB[:CASEWORKER]
caseworkers.update(FAX_NO: nil, TEL_NO: nil)

caseworkers.select(:CASEWORKER_ID).all.each do |row|
  name = "#{Faker::Name.first_name} #{Faker::Name.last_name}"
  login = Faker::Internet.username(specifier: name)
  email = Faker::Internet.email(name: name)

  caseworkers
    .where(CASEWORKER_ID: row[:caseworker_id])
    .update(LOGIN_NAME: login, FULL_NAME: name, EMAIL: email)
end

logger.info('FIN.')
