class Student {
  final String firstName;
  final String lastName;
  final String dob;
  final String? address1;
  final String? address2;
  final String cityN;
  final String state;
  final String? zip;
  final String contactNo;
  final String emailId;
  final int pid;
  final String gender;
  final String universalId;
  final String bloodGroup;

  Student({
    required this.firstName,
    required this.lastName,
    required this.dob,
    this.address1,
    this.address2,
    required this.cityN,
    required this.state,
    this.zip,
    required this.contactNo,
    required this.emailId,
    required this.pid,
    required this.gender,
    required this.universalId,
    required this.bloodGroup,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      firstName: json['first_name'],
      lastName: json['last_name'],
      dob: json['dob'],
      address1: json['address_1'],
      address2: json['address_2'],
      cityN: json['city_n'],
      state: json['state'],
      zip: json['zip'],
      contactNo: json['contact_no'],
      emailId: json['email_id'],
      pid: json['pid'],
      gender: json['gender'],
      universalId: json['universal_id'],
      bloodGroup: json['blood_group'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'dob': dob,
      'city_n': cityN,
      'state': state,
      'contact_no': contactNo,
      'pid': pid,
    };
  }
}