pub contract Scriborrr {

    pub var numberOfBlogspacesCreated: UInt64

	pub resource Blogspace {

        pub var blogs: @{UInt64 : blog}

        init() {
            self.blogs <- {}
        }

        destroy() {
            destroy self.blogs
        }

        pub fun addblog(title: String, body: String) {
            let oldblog <- self.blogs[blog.uuid] <- blog
            destroy oldblog
        }

        pub fun editblog(blogID: UInt64, newTitle: String, newBody: String) {
            let oldblog <- self.blogs.insert(key: blogID, <- create blog(title: newTitle, body: newBody))
            destroy oldblog
        }

        pub fun deleteblog(blogID: UInt64) { 
            let blog <- self.blogs.remove(key: blogID)
            destroy blog
        }

        pub fun blog(blogID: UInt64): blogDTO {
            var blog <- self.blogs.remove(key: blogID)!
            let blogDTO = blogDTO(id: blogID, title: blog.title, body: blog.body)
            
            let oldblog <- self.blogs[blogID] <- blog
            destroy oldblog
            return blogDTO
        }

        pub fun allblogs(): [blogDTO] { 
            var allblogs: [blogDTO] = []
            for key in self.blogs.keys {
                allblogs.append(self.blog(blogID: key))
            }

            return allblogs
        }
	}

	pub resource blog {
        pub(set) var title: String
        pub(set) var body: String

        init(title: String, body: String) {
            self.title = title 
            self.body = body
        }
	}

    pub struct blogDTO {
        pub let id: UInt64
        pub let title: String
        pub let body: String

        init(id: UInt64, title: String, body: String) {
            self.id = id
            self.title = title 
            self.body = body
        }
    }

    init() {
        self.numberOfBlogspacesCreated = 0
    }


    pub fun createBlogspace(): @Blogspace {
        self.numberOfBlogspacesCreated = self.numberOfBlogspacesCreated + 1
        return <- create Blogspace()
    }

    pub fun deleteBlogspace(Blogspace: @Blogspace) {
        self.numberOfBlogspacesCreated = self.numberOfBlogspacesCreated > 0 ? self.numberOfBlogspacesCreated - 1 : 0
        destroy Blogspace
    }
}

