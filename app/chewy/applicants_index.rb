class ApplicantsIndex < Chewy::Index
  define_type User.applicant.includes(:job_types, :educations, :skills, :user_profile) do
    witchcraft!
    field :id, type: "integer", value: -> {id}
    field :name, value: -> {name}
    field :email, value: -> {email}
    field :address, value: -> {address}
    field :job_types, value: -> {job_types.pluck :name}
    field :schools, value: -> {educations.pluck :school}
    field :skills, value: -> {skills.pluck :name}
    field :position, value: -> {user_profile.current_position if user_profile}
  end

  class << self
    def suggest_to_applicant applicant
      query(bool: {
        must_not: [
          {match: {id: applicant.id}},
          {terms: {id: applicant.followeds.pluck(:followed_id)}}
        ],
        should: [
          {match: {
            address: {
              query: applicant.address,
              boost: 6
            }
          }},
          {match: {
            schools: {
              query: applicant.educations.pluck(:school).join(" "),
              boost: 5
            }
          }},
          {match: {job_types: applicant.job_types.pluck(:name).join(" ")}},
          {match: {skills: applicant.skills.pluck(:name).join(" ")}},
          {match: {position: applicant.user_profile ? applicant.user_profile.current_position : ""}}
        ]
      })
    end
    def suggest_to_recruiter recruiter
      query(bool: {
        must_not: {terms: {id: recruiter.followeds.pluck(:followed_id)}},
        should: [
          {match: {address: recruiter.address}},
          {match: {
            job_types: {
              query: recruiter.job_types.pluck(:name).join(" "),
              boost: 2
            }
          }}
        ]
      })
    end
  end
end
