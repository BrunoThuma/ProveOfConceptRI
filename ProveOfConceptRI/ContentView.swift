//
//  ContentView.swift
//  ProveOfConceptRI
//
//  Created by Bruno Thuma on 29/03/23.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var pickedItemFromGallery: PhotosPickerItem?
    @State var surveyId: String?
    @State var param2: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                PhotosPicker("Select image for",
                             selection: $pickedItemFromGallery,
                             matching: .images)
                .buttonStyle(.borderedProminent)
                if let p1 = surveyId, let p2 = param2 {
                    VStack {
                        Text("Received parameters")
                        Text(p1)
                        Text(p2)
                    }
                } else {
                    Text("No parameters received")
                }
//                NavigationLink(
//                    "Go to CameraView",
//                    destination: CameraView())
                
                Button("Open Stage without image", action: callStage)
                    .buttonStyle(.borderedProminent)
            }
        }
        .onOpenURL(perform: handleDeepLinkCall(using:))
        .onChange(of: pickedItemFromGallery, perform: loucuradaDasImages(_:))
    }
    
    private func loucuradaDasImages(_ : any Equatable) {
        let imagePickingTask = Task {
            if let selectedImage: UIImage = await selectImageFromGallery() {
                do {
                    
                    let imagePath = try storeImageToDocuments(image: selectedImage, forKey: "PocRiImage")
                    
                    if let surveyId = self.surveyId {
                        callStage(
                            withSurveyId: surveyId,
                            withImagePath: imagePath)
                    } else {
                        print("Não foi possivel ler valor de surveyId: \(surveyId)")
                    }
                    
                } catch (let err) {
                    print("Não foi possivel salvar a imagem \(err)")
                }
                
            } else {
                print("Não foi possivel selecionar imagem da galeria")
            }
        }
    }
    
    private func callStage() {
        self.callStage(
            withSurveyId: "PocriCouldNotGetSurveyId",
            withImagePath: "UrlToTheDummy")
    }
    
    private func callStage(withSurveyId surveyId: String, withImagePath urlToImage: String) {
        
        let deepLinkUrlString = "stage://deeplink?surveyId=\(surveyId)&dummyImageLink=\(urlToImage)"
        
        if let deepLinkURL = URL(string: deepLinkUrlString) {
                        UIApplication.shared.open(deepLinkURL, options: [:], completionHandler: nil)
                    }
    }
    
    private func handleDeepLinkCall(using url: URL) {
        if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let params = urlComponents.queryItems {
            surveyId = params.first(where: { $0.name == "surveyId" })?.value
            param2 = params.first(where: { $0.name == "param2" })?.value
        }
    }
    
    private func selectImageFromGallery() async -> UIImage? {
        let selectImageTask = Task {
            print("Selecionando imagem da galeria")
            if let data = try? await pickedItemFromGallery?.loadTransferable(type: Data.self) {
                return UIImage(data: data)
            }
            
            return nil
        }
        
        return await selectImageTask.value
    }
    
    private func filePathForPngExtension(forKey key: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory,
                                                in: FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
        
        return documentURL.appendingPathComponent(key + ".png")
    }
    
    // Returns String with file path if succeds on saving, throws if error
    private func storeImageToDocuments(image: UIImage,
                                       forKey key: String) throws -> String {
        guard let pngRepresentation = image.pngData() else {
            throw ImageStoringErrors.couldNotParseAsData
        }
        guard let filePath = filePathForPngExtension(forKey: key) else {
            throw ImageStoringErrors.couldNotGeneratePath
        }
        
        do  {
            try pngRepresentation.write(to: filePath,
                                        options: .atomic)
            return filePath.description
        } catch let err {
            print("Saving file resulted in error: ", err)
            throw err
        }
    }
}

enum ImageStoringErrors: Error {
    case couldNotParseAsData
    case couldNotGeneratePath
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
