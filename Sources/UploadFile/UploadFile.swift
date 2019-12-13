import Foundation

enum UploadResponse: Error {
    case success(answer: Any)
    case error(description: String)
}

struct UploadFile {
    
    static let shared = UploadFile()
    init(){}
    
    func uploadRequest(url: String, data: Data, key: String, filename: String, filetype: String, withCompletion completion: @escaping (UploadResponse) -> Void) {
        
        guard let myUrl = URL(string: url) else {
            completion(UploadResponse.error(description: "Error: Invalid URL"))
            return
        }
        
        var request = URLRequest(url: myUrl)
        request.httpMethod = "POST"
        
        let boundary = UploadFile.shared.generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        let body: Data = UploadFile.shared.createBody(key: key,
                                                      data: data,
                                                      boundary: boundary,
                                                      filename: filename,
                                                      filetype: filetype)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
            do {
                if let data = data {
                    let response = try JSONSerialization.jsonObject(with: data, options: [])
                    completion(UploadResponse.success(answer: response))
                }
                else {
                    completion(UploadResponse.error(description: "Error: Server not working..."))
                }
            } catch let error as NSError {
                completion(UploadResponse.error(description: "Error: \(error.localizedDescription)"))
            }
        }
        task.resume()
    }
    
    private func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    
    private func createBody(key: String,
                            data: Data,
                            boundary: String,
                            filename:String,
                            filetype:String) -> Data {
        var body = Data()
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\r\n")
        
        
        body.appendString("Content-Type: \(filetype)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--\(boundary)--\r\n")
        return body
    }
}



extension Data {
    mutating func appendString(_ string: String) {
        let data = string.data(
            using: String.Encoding.utf8,
            allowLossyConversion: true)
        append(data!)
    }
}


