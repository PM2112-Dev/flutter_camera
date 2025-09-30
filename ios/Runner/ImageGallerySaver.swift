import Foundation
import Photos
import UIKit

class ImageGallerySaver: NSObject {

    // Save image to gallery
    func saveImageToGallery(
        imageData: Data,
        fileName: String,
        completion: @escaping (Bool, String?) -> Void
    ) {
        // Check photo library permission
        let status = PHPhotoLibrary.authorizationStatus()

        if status == .notDetermined {
            // Request permission
            PHPhotoLibrary.requestAuthorization { [weak self] newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self?.performSaveImage(
                            imageData: imageData,
                            fileName: fileName,
                            completion: completion
                        )
                    } else {
                        completion(false, "Photo library permission denied")
                    }
                }
            }
        } else if status == .authorized || status == .limited {
            // Permission already granted
            performSaveImage(
                imageData: imageData,
                fileName: fileName,
                completion: completion
            )
        } else {
            // Permission denied
            completion(false, "Photo library permission denied")
        }
    }

    private func performSaveImage(
        imageData: Data,
        fileName: String,
        completion: @escaping (Bool, String?) -> Void
    ) {
        guard let image = UIImage(data: imageData) else {
            completion(false, "Invalid image data")
            return
        }

        PHPhotoLibrary.shared().performChanges(
            {
                // Create asset creation request
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: imageData, options: nil)

                // Set filename if provided
                if !fileName.isEmpty {
                    creationRequest.creationDate = Date()
                }

            },
            completionHandler: { success, error in
                DispatchQueue.main.async {
                    if success {
                        completion(true, "Image saved to gallery successfully")
                    } else {
                        let errorMessage = error?.localizedDescription ?? "Unknown error occurred"
                        completion(false, "Failed to save image: \(errorMessage)")
                    }
                }
            })
    }

    // Check permission status
    func checkPermission() -> (isGranted: Bool, status: Int) {
        let status = PHPhotoLibrary.authorizationStatus()
        return (
            isGranted: status == .authorized || status == .limited,
            status: status.rawValue
        )
    }

    // Request permission
    func requestPermission(completion: @escaping (Bool, Int) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(
                    status == .authorized || status == .limited,
                    status.rawValue
                )
            }
        }
    }
}
