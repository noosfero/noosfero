require 'csv'

class CustomFormsPlugin::CsvHandler

  DEFAULT_COLUMNS = [_("Name"), _("Email")]

  class InvalidAlternativeError < RuntimeError
    def initialize(message, col_num)
      @message = message
      @col_num = col_num
    end
    attr_reader :message

    def col_num
      @col_num + DEFAULT_COLUMNS.size
    end
  end

  def initialize(form)
    @form = form
    @fields = form.fields
  end

  def generate_csv
    CSV.generate do |csv|
      csv << ([_('Timestamp')] + DEFAULT_COLUMNS + @fields.map(&:name))
      @form.submissions.each do |submission|
        csv << submission_row(submission)
      end
    end
  end

  def generate_template
    fields = @fields.map do |field|
      caption = field.alternatives.map(&:label)
                                  .to_sentence(two_words_connector: _(" or "),
                                               last_word_connector: _(', or '))
      caption.present? ? "#{field.name} (#{field.description}: #{caption})"
                       : field.name
    end
    CSV.generate do |csv|
      csv << (DEFAULT_COLUMNS + fields)
      csv << ([""] * (DEFAULT_COLUMNS.size + fields.size))
    end
  end

  def import_csv(content)
    csv_content = CSV.parse(content)
    header = csv_content.shift
    report = { header: header, success_count: 0, errors: [] }

    csv_content.each_with_index do |row, row_num|
      row_num += 2 # to ignore the header and reflect the actual line number
      begin
        submission = submission_from_row(row.dup)
        if submission.save
          report[:success_count] += 1
        else
          errors = errors_with_cols(submission.errors)
          report[:errors] << { row_number: row_num, row: row, errors: errors }
        end
      rescue InvalidAlternativeError => e
        errors = { e.col_num => [e.message] }
        report[:errors] << { row_number: row_num, row: row, errors: errors }
      end
    end
    report
  end

  private

  def submission_row(subm)
    row = default_values(subm)
    @fields.each do |field|
      row << subm.answer_for(field).to_s
    end
    row
  end

  def default_values(subm)
    timestamp = subm.updated_at.strftime('%Y/%m/%d %T %Z')
    name = subm.author_name
    email = subm.profile.present? ? subm.profile.email : subm.author_email
    [timestamp, name, email]
  end

  def submission_from_row(row)
    submission = @form.submissions.new
    row = remove_default_values(row, submission)
    @fields.each_with_index do |field, index|
      submission.answers << build_answer(field, row[index], index)
    end
    submission
  end

  def remove_default_values(row, submission)
    submission.author_name = row.shift
    submission.author_email = row.shift
    row
  end

  def build_answer(field, value, col_num)
    if field.is_a? CustomFormsPlugin::SelectField
      labels = value.split(';')
      ids = labels.map do |label|
        alternative = field.alternatives.find_by(label: label)
        unless alternative
          raise InvalidAlternativeError.new(_('Invalid alternative'), col_num)
        end
        alternative.id
      end
      CustomFormsPlugin::Answer.new(field: field, value: ids.join(','))
    else
      CustomFormsPlugin::Answer.new(field: field, value: value)
    end
  end

  def errors_with_cols(errors)
    with_cols = {}
    errors.each do |key|
      with_cols[0] = errors[key] if key == :author_name
      with_cols[1] = errors[key] if key == :author_email
      @fields.each_with_index do |field, index|
        if key.to_s == field.id.to_s
          with_cols[index + DEFAULT_COLUMNS.size] = errors[key]
        end
      end
    end
    with_cols
  end

end
