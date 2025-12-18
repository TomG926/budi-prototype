# Service to provide industry-specific prompts and instructions for Power BI analysis
class IndustryPromptsService
  PROMPTS = {
    salon: {
      name: "Salon & Beauty Services",
      description: "Analyze salon appointment data, service performance, and client trends",
      power_bi_prompts: [
        "What are the most popular services by revenue?",
        "Which staff members generate the highest revenue?",
        "What are the peak booking times and days?",
        "What is the average service price and how does it vary by service type?",
        "Which clients have the highest lifetime value?",
        "What is the average tip percentage by service type?",
        "How does product sales correlate with services?",
        "What are the booking patterns and cancellation rates?"
      ],
      key_metrics: [
        "Revenue by service type",
        "Revenue by staff member",
        "Appointments per day/week",
        "Average service duration",
        "Client retention rate",
        "Product sales vs service revenue"
      ],
      visualizations: [
        "Time series: Revenue trends over time",
        "Key Influencers: What drives revenue",
        "Anomaly Detection: Unusual booking patterns",
        "Decomposition Tree: Revenue by service → staff → time period"
      ]
    },
    retail: {
      name: "Retail",
      description: "Analyze sales, inventory, and customer purchasing patterns",
      power_bi_prompts: [
        "What are the best-selling products by revenue and quantity?",
        "Which categories or departments perform best?",
        "What are the sales trends by day of week or time of day?",
        "Which customers are the most valuable?",
        "What is the average order value and how does it vary?",
        "What products are frequently bought together?",
        "How do discounts affect sales volume?",
        "What are the seasonal sales patterns?"
      ],
      key_metrics: [
        "Total revenue",
        "Units sold by product/category",
        "Average transaction value",
        "Sales by location/region",
        "Customer lifetime value",
        "Return rate"
      ],
      visualizations: [
        "Sales trends over time",
        "Product performance matrix",
        "Geographic sales distribution",
        "Customer segmentation"
      ]
    },
    restaurant: {
      name: "Restaurant & Food Service",
      description: "Analyze menu performance, reservations, and dining patterns",
      power_bi_prompts: [
        "What are the most popular menu items?",
        "What are the peak dining hours and days?",
        "What is the average check size and how does it vary?",
        "Which servers or sections perform best?",
        "How do reservations correlate with walk-ins?",
        "What are the customer wait times?",
        "How does menu pricing affect order patterns?",
        "What are the seasonal dining trends?"
      ],
      key_metrics: [
        "Revenue by menu item/category",
        "Cover count",
        "Average check size",
        "Table turnover rate",
        "Peak hours analysis",
        "Reservation vs walk-in ratio"
      ],
      visualizations: [
        "Revenue by menu category",
        "Peak hours heatmap",
        "Server performance comparison",
        "Menu item profitability"
      ]
    },
    healthcare: {
      name: "Healthcare",
      description: "Analyze patient visits, treatments, and healthcare metrics",
      power_bi_prompts: [
        "What are the most common procedures or treatments?",
        "Which providers see the most patients?",
        "What are the appointment booking patterns?",
        "What is the average visit duration?",
        "How do patient outcomes vary by treatment?",
        "What are the peak scheduling times?",
        "How does insurance type affect utilization?",
        "What are the patient no-show rates?"
      ],
      key_metrics: [
        "Patient visits by type",
        "Provider utilization",
        "Treatment outcomes",
        "Appointment scheduling efficiency",
        "Revenue by service type",
        "Patient satisfaction scores"
      ],
      visualizations: [
        "Treatment frequency analysis",
        "Provider performance dashboard",
        "Patient flow analysis",
        "Outcome trends over time"
      ]
    },
    professional_services: {
      name: "Professional Services",
      description: "Analyze billable hours, projects, and client relationships",
      power_bi_prompts: [
        "What are the billable hours by project or client?",
        "Which team members are most productive?",
        "What are the most profitable service types?",
        "How do project timelines affect profitability?",
        "What is the utilization rate by team member?",
        "Which clients generate the most revenue?",
        "How do project phases affect billing?",
        "What are the project completion trends?"
      ],
      key_metrics: [
        "Billable hours",
        "Revenue by client/project",
        "Utilization rate",
        "Average hourly rate",
        "Project profitability",
        "Client retention"
      ],
      visualizations: [
        "Time tracking by project",
        "Team utilization dashboard",
        "Client profitability analysis",
        "Project pipeline status"
      ]
    },
    ecommerce: {
      name: "E-commerce",
      description: "Analyze online sales, customer behavior, and conversion metrics",
      power_bi_prompts: [
        "What are the best-selling products?",
        "What is the conversion rate by traffic source?",
        "What are the cart abandonment patterns?",
        "Which customer segments are most valuable?",
        "How do promotions affect sales?",
        "What are the shipping and fulfillment patterns?",
        "How does seasonality affect sales?",
        "What are the customer acquisition costs?"
      ],
      key_metrics: [
        "Conversion rate",
        "Average order value",
        "Customer lifetime value",
        "Traffic sources",
        "Cart abandonment rate",
        "Return rate"
      ],
      visualizations: [
        "Sales funnel analysis",
        "Customer journey mapping",
        "Product performance matrix",
        "Marketing channel effectiveness"
      ]
    },
    fitness: {
      name: "Fitness & Wellness",
      description: "Analyze class attendance, memberships, and fitness metrics",
      power_bi_prompts: [
        "What are the most popular classes or programs?",
        "What are the peak attendance times?",
        "Which trainers or instructors are most popular?",
        "What is the member retention rate?",
        "How does class schedule affect attendance?",
        "What are the membership revenue trends?",
        "How do personal training sessions correlate with membership?",
        "What are the seasonal attendance patterns?"
      ],
      key_metrics: [
        "Class attendance",
        "Member retention",
        "Revenue by class type",
        "Peak usage times",
        "Personal training bookings",
        "Membership conversion rate"
      ],
      visualizations: [
        "Class popularity analysis",
        "Attendance heatmap by time/day",
        "Member retention trends",
        "Revenue by program type"
      ]
    },
    education: {
      name: "Education",
      description: "Analyze enrollment, courses, and student performance",
      power_bi_prompts: [
        "What are the most popular courses or programs?",
        "What are the enrollment trends?",
        "How do course fees vary by program?",
        "What is the student retention rate?",
        "Which instructors have the highest enrollment?",
        "How do course schedules affect enrollment?",
        "What are the completion rates?",
        "How does pricing affect enrollment?"
      ],
      key_metrics: [
        "Enrollment by course",
        "Student retention",
        "Revenue by program",
        "Completion rates",
        "Average class size",
        "Instructor performance"
      ],
      visualizations: [
        "Course popularity trends",
        "Enrollment patterns over time",
        "Instructor performance comparison",
        "Student progression analysis"
      ]
    },
    other: {
      name: "Other",
      description: "General business data analysis",
      power_bi_prompts: [
        "What are the revenue trends over time?",
        "Which categories or segments perform best?",
        "What are the peak periods of activity?",
        "How do different variables correlate?",
        "What are the key performance indicators?",
        "What patterns can be identified in the data?",
        "What are the outliers or anomalies?",
        "How can we optimize performance?"
      ],
      key_metrics: [
        "Revenue trends",
        "Volume metrics",
        "Performance indicators",
        "Trend analysis",
        "Comparative metrics"
      ],
      visualizations: [
        "Time series analysis",
        "Key influencers",
        "Anomaly detection",
        "Comparative analysis"
      ]
    }
  }.freeze

  def self.for_industry(industry_type)
    PROMPTS[industry_type&.to_sym] || PROMPTS[:other]
  end

  def self.all_industries
    PROMPTS.map { |key, value| [value[:name], key.to_s] }
  end
end

