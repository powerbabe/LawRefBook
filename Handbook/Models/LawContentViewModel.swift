import Foundation
import SwiftUI

extension LawContentView {
    
    class LawContentViewModel: ObservableObject {

        @Published
        fileprivate(set) var isLoading = false

        @Published
        var scrollPos: Int64? = nil

        @Published
        fileprivate(set) var hasToc = false
        
        @Published
        fileprivate(set) var isFav = false

        @Published
        fileprivate(set) var isSearchSubmit = false

        @Published
        fileprivate(set) var titles = [String]()

        @Published
        fileprivate(set) var body = [TextContent]()
        
        fileprivate(set) var lawID: UUID
        fileprivate(set) var content: LawContent
        fileprivate var queue = DispatchQueue(label: "contentVM", qos: .background)
        
        var searchText: String = ""

        init(_ id: UUID) {
            lawID = id
            content = LawProvider.shared.getLawContent(id)
        }
        
        private var isLoaded = false
        func onAppear() {
            if isLoaded {
                return
            }
            isLoaded =  true
            self.loadContent()
            isFav = LawProvider.shared.getFavoriteState(self.lawID)
        }

        private func loadContent() {
            self.isLoading = true
            queue.async {
                self.content.load()
                DispatchQueue.main.async {
                    withAnimation {
                        self.titles = self.content.Titles
                        self.body = self.content.Body
                        self.hasToc = self.content.hasToc()
                        self.isLoading = false
                    }
                }
            }
        }

        func onFavIconClicked() {
            LawProvider.shared.favoriteLaw(lawID)
            isFav = !isFav
        }

        func doSearchText(_ txt: String) {
            searchText = txt
            isSearchSubmit = true
            isLoading = true
            queue.async {
                let arr = self.content.filterText(text: txt)
                DispatchQueue.main.async {
                    self.body = arr
                    self.isLoading = false
                }
            }
        }

        func clearSearchState() {
            searchText = ""
            isSearchSubmit = false
            self.body = self.content.Body
        }

    }
    
}
