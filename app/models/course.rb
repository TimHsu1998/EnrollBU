class Course < ApplicationRecord

  #def validate
    #need to valudate the input is right or wrong
  #end

  belongs_to :user

  validates :name, presence: true
  validates :college, presence: true
  validates :department, presence: true
  validates :number, presence: true
  validates :section, presence: true
  validates :add_or_swap, presence: true
  validates :loginemail, presence: true
  validates :loginpassword, presence: true

  #Register to the courses
  def self.register
    Rails.logger.info("BUregis updated at #{Time.now}")
    @courses = Course.where(enrolledin: false).order("created_at ASC")
    @courses = @courses.uniq{ |course|[course[:college],course[:department],course[:number],course[:section]]}
    @courses.each do |course|
      check_course(course)
    end
  end

  #login and check the course is open or not
  def self.check_course(course)
    headless = Headless.new
    headless.start
    Selenium::WebDriver::Chrome.driver_path = "/usr/local/bin/chromedriver"
    browser = Watir::Browser.new :chrome, :switches => %w[--no-sandbox]
        # go login to registration
    browser.goto 'https://www.bu.edu/link/bin/uiscgi_studentlink.pl/1516080925?ModuleName=menu.pl&NewMenu=Academics'
    browser.link(:text =>"Registration").when_present.click
    browser.input(:name => 'j_username').send_keys "#{course.loginemail}"
    browser.input(:name => 'j_password').send_keys "#{course.loginpassword}"
    browser.button(:name => '_eventId_proceed').click
    browser.link(:text =>"Reg Options").when_present.click
    browser.link(:text =>"Register for Class").when_present.click

    #put in lecture
    browser.input(:name => 'College1').send_keys "#{course.college}"
    browser.input(:name => 'Dept1').send_keys "#{course.department}"
    browser.input(:name => 'Course1').send_keys "#{course.number}"
    browser.input(:name => 'Section1').send_keys "#{course.section}"

    lab_numbers = 0

    #put_lab_begin
    #put in lab1
    if course.lab1 != ''
      browser.input(:name => "College2").send_keys "#{course.college}"
      browser.input(:name => "Dept2").send_keys "#{course.department}"
      browser.input(:name => "Course2").send_keys "#{course.number}"
      browser.input(:name => "Section2").send_keys "#{course.lab1}"
      lab_numbers += 1

      #put in lab2
      if course.lab2 != ''
        browser.input(:name => "College3").send_keys "#{course.college}"
        browser.input(:name => "Dept3").send_keys "#{course.department}"
        browser.input(:name => "Course3").send_keys "#{course.number}"
        browser.input(:name => "Section3").send_keys "#{course.lab2}"
        lab_numbers += 1

        #put in lab3
        if course.lab3 != ''
          browser.input(:name => "College4").send_keys "#{course.college}"
          browser.input(:name => "Dept4").send_keys "#{course.department}"
          browser.input(:name => "Course4").send_keys "#{course.number}"
          browser.input(:name => "Section4").send_keys "#{course.lab3}"
          lab_numbers += 1

          #put in lab4
          if course.lab4 != ''
            browser.input(:name => "College5").send_keys "#{course.college}"
            browser.input(:name => "Dept5").send_keys "#{course.department}"
            browser.input(:name => "Course5").send_keys "#{course.number}"
            browser.input(:name => "Section5").send_keys "#{course.lab4}"
            lab_numbers += 1
          end
        end
      end
    end
    #put_lab_end

    #search
    browser.button(:onclick => "SearchNbr()").click

    #check course is open or not
    opened_section = check_open(browser, course)
    if opened_section == false
      #if there's no open section, close the browser
      browser.close
    else
      #if there's open section, check course is add or swap
      if course.add_or_swap == "add"
        # just add course
        if lab_numbers == 0
          enroll_course(browser)
        else
          enroll_course_with_lab(browser, course, opened_section)
        end
        if check_success(browser)
          course.enrolledin = true
        end
      elsif course.add_or_swap == "swap"
        # swap course: drop --> enroll
        drop_course(browser, course)
        if lab_numbers == 0
          browser.goto 'https://www.bu.edu/link/bin/uiscgi_studentlink.pl/1516080925?ModuleName=menu.pl&NewMenu=Academics'
          browser.link(:text =>"Registration").when_present.click
          browser.link(:text =>"Reg Options").when_present.click
          browser.link(:text =>"Register for Class").when_present.click

          #put in lecture
          browser.input(:name => 'College1').send_keys "#{course.college}"
          browser.input(:name => 'Dept1').send_keys "#{course.department}"
          browser.input(:name => 'Course1').send_keys "#{course.number}"
          browser.input(:name => 'Section1').send_keys "#{course.section}"
          browser.button(:onclick => "SearchNbr()").click
          enroll_course(browser)
        else
          enroll_course_with_lab(browser,course, opened_section)
        end
      end
    end
  end

  def self.check_open(browser, course)
    #check course is open or not
    @doc = Nokogiri::HTML(browser.html)
    @tr = @doc.css('form > table:nth-child(1) > tbody > tr')

    tr_line = find_tr_line(@tr, course.section, true)

    opened_course = [0]

    if browser.img(:css, "form > table > tbody > tr:nth-child(#{tr_line}) > td:nth-child(1) > a > img").exists?
      # if the flag of the course exists, it's not open
      return false
    else
      # if the flag doesn't exist go check other section
      for i in 1..4
        if browser.input(:css, "form > table > tbody > tr:nth-child(#{tr_line + i}) > td:nth-child(1) > input").exists?
          opened_course += [i]
        end
      end
    end
    if course.lab1 == '' #if course dosen't have lab
      return opened_course
    elsif opened_course[1] != nil #if course has lab
      return opened_course
    else #if course has lab, but there's no lab section open
      return false
    end

  end

  def self.enroll_course(browser)
    browser.button(:onclick => "AddClasses();").click
    browser.alert.ok
    sleep 0.5
    check_success(browser)
    if check_success(browser)
      course.enrolledin = true
    end
    browser.close
  end

  def self.enroll_course_with_lab(browser, course, opened_section)
    browser.goto 'https://www.bu.edu/link/bin/uiscgi_studentlink.pl/1516080925?ModuleName=menu.pl&NewMenu=Academics'
    browser.link(:text =>"Registration").when_present.click
    browser.link(:text =>"Reg Options").when_present.click
    browser.link(:text =>"Register for Class").when_present.click

    #put in lecture and lab
    browser.input(:name => 'College1').send_keys "#{course.college}"
    browser.input(:name => 'Dept1').send_keys "#{course.department}"
    browser.input(:name => 'Course1').send_keys "#{course.number}"
    browser.input(:name => 'Section1').send_keys "#{course.section}"
    browser.input(:name => "College2").send_keys "#{course.college}"
    browser.input(:name => "Dept2").send_keys "#{course.department}"
    browser.input(:name => "Course2").send_keys "#{course.number}"
    if opened_section.include?(1)
      browser.input(:name => "Section2").send_keys "#{course.lab1}"
    elsif opened_section.include?(2)
      browser.input(:name => "Section2").send_keys "#{course.lab2}"
    elsif opened_section.include?(3)
      browser.input(:name => "Section2").send_keys "#{course.lab3}"
    elsif opened_section.include?(4)
      browser.input(:name => "Section2").send_keys "#{course.lab4}"
    end
    browser.button(:onclick => "SearchNbr()").click
    enroll_course(browser)
  end

  def self.drop_course(browser, course)
    browser.goto 'https://www.bu.edu/link/bin/uiscgi_studentlink.pl/1516080925?ModuleName=menu.pl&NewMenu=Academics'
    browser.link(:text =>"Registration").when_present.click
    browser.link(:text =>"Reg Options").when_present.click
    browser.link(:text =>"Drop Class").when_present.click

    @doc = Nokogiri::HTML(browser.html)
    @tr = @doc.css('body > table:nth-child(6) > tbody > tr')
    section = course.swapped_department + course.swapped_number
    tr_line = find_tr_line(@tr, section, false)

    browser.checkbox(:css, "body > table:nth-child(6) > tbody > tr:nth-child(#{tr_line}) > td:nth-child(1) > input[type='checkbox']").set

    if course.swapped_lab != ''
      browser.checkbox(:css, "body > table:nth-child(6) > tbody > tr:nth-child(#{tr_line+1}) > td:nth-child(1) > input").set
    end
    browser.button(:onclick => "DropClasses()").click
    browser.alert.ok
  end

  #find tr is section in registeration
  def self.find_tr_line(trs, section, have_extra_td)
    if have_extra_td
      trs.each_with_index do |tr, index|
        if tr.css('td:nth-child(3)').text.include?(section)
          return index + 1
        end
      end
    else
      trs.each_with_index do |tr, index|
        if tr.css('td:nth-child(2)').text.include?(section)
          return index + 1
        end
      end
    end
  end

  def self.check_success(browser)
    if browser.img(:css, 'img[src="https://www.bu.edu/link/student/images/xmark.gif"]').exists?
      return false
    else
      return true
    end
  end

  def add_original_back(browser,course)
    browser.goto 'https://www.bu.edu/link/bin/uiscgi_studentlink.pl/1516080925?ModuleName=menu.pl&NewMenu=Academics'
    browser.link(:text =>"Registration").when_present.click
    browser.link(:text =>"Reg Options").when_present.click
    browser.link(:text =>"Register for Class").when_present.click

    #put in lecture and lab
    browser.input(:name => 'College1').send_keys "#{course.swapped_college}"
    browser.input(:name => 'Dept1').send_keys "#{course.swapped_department}"
    browser.input(:name => 'Course1').send_keys "#{course.swapped_number}"
    browser.input(:name => 'Section1').send_keys "#{course.swapped_section}"
    if course.swapped_lab != ''
      browser.input(:name => "College2").send_keys "#{course.swapped_college}"
      browser.input(:name => "Dept2").send_keys "#{course.swapped_department}"
      browser.input(:name => "Course2").send_keys "#{course.swapped_number}"
      browser.input(:name => "Section2").send_keys "#{course.swapped_lab}"
    end
    browser.button(:onclick => "SearchNbr()").click

    enroll_course(browser)
  #def email
    #if the add_back is false, email the admin and user
  #end

  end
end
