Hi Tobassum - Welcome to G2C. Here's your first assignment - real work that directly supports one of our portfolio companies and an upcoming founder meeting.

Background
Actual.ai helps engineering teams govern AI-generated code through Architecture Decision Records (ADRs) - rules that tell AI agents how code should be written. We need to know if the product works and whether we can prove its ROI in dollars. Your findings will be used in real investor and sales conversations.

---

PHASE 1 - Monica (weeks 1-3)
github.com/monicahq/monica
24K stars, 49 active PRs, built on Laravel. Small enough to set up in a day, clear enough architecture to test properly.

Step 1 - Get access to Actual.ai
- Join waitlist at actual.ai using your G2C email
- Also try the ADR Bot from the homepage - may not need waitlist approval
- We are emailing company to fast-track you
- No response within 2 days - ping us immediately

Step 2 - Set up Monica locally
- Fork github.com/monicahq/monica to your GitHub account
- Clone your fork locally
- Follow the README setup instructions (Laravel/PHP project)
- Create a new branch called adr-test
- Screenshot every step - note anything that takes more than 10 minutes

Step 3 - Connect Actual.ai to your Monica fork
- Connect your forked repo to Actual.ai
- Document: did it auto-detect existing architectural patterns or did you have to define them manually?
- Screenshot the ADR list it generates

Step 4 - Make 3 intentional architectural violations

Violation 1 - Business logic in controller
Find a controller in app/Http/Controllers and add direct database queries that should live in a Service class

Violation 2 - Hardcoded config value
Hardcode an API key or URL that should use Laravel's config() or env() helper

Violation 3 - Skip an interface
Find a class that implements an interface consistently and create a similar class without implementing it

Create a PR from your adr-test branch. Document: did Actual.ai catch each violation, how specific was the feedback, how long did it take?

---

Step 5 - ONE shared metric (most important deliverable)
One-metric anchor to one number that a CTO and CFO can agree on in the same room without arguing.

That number is: Cost Per Feature Shipped
Total AI tool spend divided by features delivered to production that month

CTO reads it as: are we shipping efficiently
CFO reads it as: are we spending efficiently
Neither can argue with it because it is just math

Measure this before and after ADR implementation using the Monica test data. Show the before number and the after number. The difference is Actual.ai's value in one line.

---

Step 6 - Assessment 1: Developer ROI scorecard
For each metric answer: can Actual.ai measure it today, what data source, what dollar value?

- Rework rate per sprint
- Bugs per AI-generated PR
- Review hours saved per developer
- Violations caught before merge

Dollar logic: each caught violation = 2-4 hours senior dev time at $150/hr = $300-600 saved. On a 10-person team that is $75K-$300K annually.

Step 7 - Assessment 2: Token savings scorecard
Note: research shows ADRs may increase tokens per task by 14-22% because agents explore more thoroughly. What we CAN measure is rework loops - which silently double your AI compute bill.

Measure:
- Token cost of a clean PR (merges first time)
- Token cost of a violation PR (fails, rewrites, merges second time)
- The ratio between the two

Dollar math: clean PR = ~$0.75 in tokens. Rework cycle = ~$1.50. On 200 PRs per sprint at 20% rework rate = $1,500 annually in pure wasted compute before human time.

Step 8 - Two one-pagers anchored to the shared metric

One pager for CFO & CTO
Headline: one dollar number
Body: Cost Per Feature Shipped before vs after ADR implementation
Subtext: what drove the change in plain English
Body: what Actual.ai actually did to move that number
Subtext: rework prevented, violations caught, hours recovered

The goal: both walk out of the same meeting pointing at the same number. No translation needed between them.

---

PHASE 2 - Drupal (week 4 onwards)
Once Monica is done we move to Drupal. John knows the Drupal founder personally. Your findings there could become a live proof point in a real business meeting. We will brief you separately.

---

Deliverables by week
Week 1: Access confirmed, Monica set up, ADRs auto-detected
Week 2: 3 violations tested, results documented with screenshots
Week 3: Both scorecards, shared metric calculated, two one-pagers drafted
Week 4: Drupal phase begins

If something does not work say so. A finding that says Actual.ai missed this violation is useful data for us and for company.

Check in as often as needed - atleast every Mon, Wed, Fri. Send bullet points Thurs EOD.

Questions anytime. This will be fun and super useful :)




Regards,
- Vik
Managing Partner
G2C Ventures
(408) 836 6663