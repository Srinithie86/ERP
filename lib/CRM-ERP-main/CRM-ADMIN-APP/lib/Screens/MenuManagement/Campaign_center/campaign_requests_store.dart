class CampaignRequestsStore {
  static final List<Map<String, String>> requests = [
    {
      'requestId': 'DMC-12345001-123',
      'requestDate': '15 Jan 2024',
      'campaignName': 'Summer Sale 2024',
      'type': 'Social Media',
      'requestedBy': 'John Doe',
      'department': 'Marketing',
      'startDate': '01 Feb 2024',
      'priority': 'Normal',
      'approvalStatus': 'Approved',
      'campaignStatus': 'Requested',
      'targetAudience': 'Age 25-45, Fashion Enthusiasts',
      'targetLocation': 'Mumbai, Delhi',
      'purpose': 'Promote summer collection with 30% discount',
      'message': 'Summer discount highlights and collection launch details',
      'expectedReach': '2500',
      'notes': 'Focus on metro audiences',
    },
    {
      'requestId': 'DMC-12345002-456',
      'requestDate': '18 Jan 2024',
      'campaignName': 'Product Launch - SmartWatch Pro',
      'type': 'Email',
      'requestedBy': 'Sarah Smith',
      'department': 'Sales',
      'startDate': '10 Feb 2024',
      'priority': 'Urgent',
      'approvalStatus': 'Pending',
      'campaignStatus': 'Requested',
      'targetAudience': 'Working Professionals, Tech Buyers',
      'targetLocation': 'Bangalore, Hyderabad',
      'purpose': 'Launch the new smartwatch series to premium buyers',
      'message': 'Product features, launch benefits, and CTA for booking',
      'expectedReach': '1800',
      'notes': 'Priority launch campaign',
    },
  ];

  static void add(Map<String, String> request) {
    requests.insert(0, request);
  }

  static void delete(String requestId) {
    requests.removeWhere((item) => item['requestId'] == requestId);
  }
}
