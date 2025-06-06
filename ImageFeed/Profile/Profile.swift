struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(from result: ProfileResult) {
        self.username = result.username
        let first = result.firstName ?? ""
        let last = result.lastName ?? ""
        self.name = [first, last].filter { !$0.isEmpty }.joined(separator: " ")
        self.loginName = "@\(result.username)"
        self.bio = result.bio
    }
}
