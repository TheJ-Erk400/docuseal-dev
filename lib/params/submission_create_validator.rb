# frozen_string_literal: true

module Params
  class SubmissionCreateValidator < BaseValidator
    def call
      if params[:submission].blank? && (params[:emails].present? || params[:email].present?)
        validate_creation_from_emails(params)
      elsif params[:submitters].present?
        validate_creation_from_submitters(params)
      else
        validate_creation_from_submission(params)
      end

      true
    end

    def validate_creation_from_emails(params)
      required(params, :template_id)
      required(params, %i[emails email])

      type(params, :emails, String)
      boolean(params, :send_email)
      type(params, :message, Hash)

      in_path(params, :message) do |message_params|
        type(message_params, :subject, String)
        type(message_params, :body, String)

        required(message_params, :body)
      end
    end

    def validate_creation_from_submitters(params)
      required(params, :template_id)
      required(params, :submitters)

      boolean(params, :send_email)
      boolean(params, :send_sms)
      type(params, :order, String)
      type(params, :completed_redirect_url, String)
      type(params, :bcc_completed, String)
      type(params, :message, Hash)

      in_path(params, :message) do |message_params|
        type(message_params, :subject, String)
        type(message_params, :body, String)

        required(message_params, :body)
      end

      value_in(params, :order, %w[preserved random], allow_nil: true)

      in_path_each(params, :submitters) do |submitter_params|
        validate_submitter(submitter_params)
      end
    end

    def validate_submitter(submitter_params)
      required(submitter_params, %i[email phone name])

      type(submitter_params, :name, String)
      type(submitter_params, :email, String)
      format(submitter_params, :email, /@/, message: 'email is invalid')
      type(submitter_params, :phone, String)
      format(submitter_params, :phone, /\A\+\d+\z/,
             message: 'phone should start with +<country code> and contain only digits')
      type(submitter_params, :values, Hash)
      boolean(submitter_params, :send_email)
      boolean(submitter_params, :send_sms)
      type(submitter_params, :completed_redirect_url, String)
      type(submitter_params, :fields, Array)

      in_path_each(submitter_params, :fields) do |field_params|
        required(field_params, :name)

        type(field_params, :name, String)
        type(field_params, :validation_pattern, String)
        type(field_params, :invalid_message, String)
        boolean(field_params, :readonly)
      end
    end

    def validate_creation_from_submission(params)
      required(params, :template_id)
      required(params, %i[submission submissions])

      boolean(params, :send_email)
      boolean(params, :send_sms)
      type(params, :order, String)
      type(params, :completed_redirect_url, String)
      type(params, :bcc_completed, String)
      type(params, :message, Hash)

      in_path(params, :message) do |message_params|
        type(message_params, :subject, String)
        type(message_params, :body, String)

        required(message_params, :body)
      end

      value_in(params, :order, %w[preserved random], allow_nil: true)

      return true if params[:submission].is_a?(Array)

      in_path(params, :submission) do |submission_params|
        required(submission_params, :submitters) if params[:submission]
      end

      in_path_each(params, %i[submission submitters]) do |submitter_params|
        validate_submitter(submitter_params)
      end
    end
  end
end