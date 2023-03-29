import XCTest
import Nimble
import Transport
@testable import Feature_OverviewScreen

@MainActor
final class OverviewViewModelTests: XCTestCase {
    
    var sut: OverviewViewModel!
    private var fakeCoordinator: OverviewViewModelDelegateSpy!
    
    override func setUp() {
        super.setUp()
        
        fakeCoordinator = OverviewViewModelDelegateSpy()
    }
    
    func test_initialLoad() async {
        
        // Arrange
        let query: String? = nil
        let successNetworkService = FetchCollectionServiceFakeSpy(loadResponse: [.stub1])
        
        // Act
        sut = OverviewViewModel(initialQuery: query, fetchCollectionService: successNetworkService)

        // Assert
        expect(self.sut.title) == "Rijksmuseum Collection"
        expect(self.sut.itemUpdates.value).to(beNil()) // starts as nil
        expect(self.sut.isLoading.value).to(beTrue())
        
        // Check call to network was correct:
        await expect(successNetworkService.invokedLoadCount).toEventually(equal(1))
        await expect(successNetworkService.invokedLoadParameters).toEventually(equal((query, 1)))
        
        // Check the output of the ViewModel is correct after network load:
        let expectedValue: (OverviewViewModel.StateChangeMode, [CollectionItem])? = (
            .overwrite, [CollectionItem.from(artObject: .stub1)]
        )
        await expect(self.sut.itemUpdates.value).toEventually(equal(expectedValue))
        
        // Loading should have stopped:
        expect(self.sut.isLoading.value).to(beFalse())
    }
    
    func test_initialLoadWithGivenQuery() async {
        // Arrange
        let query: String? = "hello"
        let successNetworkService = FetchCollectionServiceFakeSpy(loadResponse: [.stub1])
        
        // Act
        sut = OverviewViewModel(initialQuery: query, fetchCollectionService: successNetworkService)

        // Assert
        expect(self.sut.title) == query // Title == query text when non-nil.
        
        // Check call to network was correct:
        await expect(successNetworkService.invokedLoadCount).toEventually(equal(1))
        await expect(successNetworkService.invokedLoadParameters).toEventually(equal((query, 1)))
    }
    
    func test_canLoadMoreDataUntilEmptyResponseReceived() async {
        // Arrange
        let query: String? = "hello"
        let successNetworkService = FetchCollectionServiceFakeSpy(loadResponse: [.stub1])
        
        sut = OverviewViewModel(initialQuery: query, fetchCollectionService: successNetworkService)
        await expect(successNetworkService.invokedLoadCount).toEventually(equal(1))
        await expect(successNetworkService.invokedLoadParameters).toEventually(equal((query, 1)))

        // Act
        successNetworkService.loadResponse = [] // next response is now EMPTY
        sut.userViewedTheLastCell() // triggers VM to load next page

        // Assert
        await expect(successNetworkService.invokedLoadCount).toEventually(equal(2))
        await expect(successNetworkService.invokedLoadParameters).toEventually(equal((query, 2))) // hitting page 2 ✔
        
        // Check a further load (should not cause any networking)
        sut.userViewedTheLastCell()
        
        // invokedLoadCount is still == 2  ✔
        await expect(successNetworkService.invokedLoadCount).toEventually(equal(2))
    }
    
    func test_loadingMoreDataAppendsRatherThanInserts() async {
        
        // First update from ViewModel is an `.overwrite` event (tested above)
        // But the next page should be `.append`:
        
        // Arrange
        let query: String? = "hello"
        let successNetworkService = FetchCollectionServiceFakeSpy(loadResponse: [.stub1])
        sut = OverviewViewModel(initialQuery: query, fetchCollectionService: successNetworkService)

        // Act
        successNetworkService.loadResponse = [.stub2] // next response is different
        sut.userViewedTheLastCell() // triggers VM to load next page

        // Assert
        let secondExpectedValue: (OverviewViewModel.StateChangeMode, [CollectionItem])? = (
            .append, [CollectionItem.from(artObject: .stub2)]
        )
        await expect(self.sut.itemUpdates.value).toEventually(equal(secondExpectedValue))
    }
    
    func test_changingSearchQueryLoadsANewPage1AndOverwrites() async {
        
        // If the search query is changed, paging should begin again at page 1.
        // It should also use `.overwrite` to update the ViewController:
        
        // Arrange
        let successNetworkService = FetchCollectionServiceFakeSpy(loadResponse: [.stub1])
        sut = OverviewViewModel(initialQuery: "First query", fetchCollectionService: successNetworkService)
        await expect(self.sut.itemUpdates.value).toEventuallyNot(beNil()) // wait for the load to complete
        
        successNetworkService.loadResponse = [.stub2] // next response is different

        // Act
        let secondQuery = "Second query"
        sut.userTypedSearchQuery(query: secondQuery)

        // Assert
        let secondExpectedValue: (OverviewViewModel.StateChangeMode, [CollectionItem])? = (
            .overwrite, [CollectionItem.from(artObject: .stub2)]
        )
        await expect(self.sut.itemUpdates.value).toEventually(equal(secondExpectedValue))
        
        await expect(successNetworkService.invokedLoadCount).toEventually(equal(2))
        // Should have fetched page 1 for `secondQuery`:
        await expect(successNetworkService.invokedLoadParameters).toEventually(equal((secondQuery, 1)))
    }
    
    func test_userCanRequestMoreInfoOnAnItem() async throws {
        // Arrange
        let successNetworkService = FetchCollectionServiceFakeSpy(loadResponse: [.stub1])
        sut = OverviewViewModel(initialQuery: "First query", fetchCollectionService: successNetworkService)
        sut.delegate = fakeCoordinator

        // wait for the load to complete
        await expect(self.sut.itemUpdates.value).toEventuallyNot(beNil())
        // get reference to first collectionitem:
        let firstCollectionItem = try XCTUnwrap(sut.itemUpdates.value?.1.first)
        
        // Act
        expect(self.fakeCoordinator.invokedUserWantsMoreInfoOnCount) == 0
        sut.userTappedCell(data: firstCollectionItem)
        
        // Assert: coordinator was called:
        expect(self.fakeCoordinator.invokedUserWantsMoreInfoOnCount) == 1
        expect(self.fakeCoordinator.invokedUserWantsMoreInfoOnParameters?.objectNumber) == firstCollectionItem.objectNumber
    }
    
    func test_networkErrorTriggersAlert() async throws {
        // Arrange
        let networkService = FetchCollectionServiceFakeSpy(loadResponse: nil) // `nil` means `throw`
        
        // Act
        sut = OverviewViewModel(initialQuery: "First query", fetchCollectionService: networkService)

        // Assert
        // wait for the load to complete
        await expect(self.sut.errorAlerts.value).toEventuallyNot(beNil())
        
        let errorAlert = try XCTUnwrap(sut.errorAlerts.value)
        guard case let .networkError(title, message, _) = errorAlert else {
            fail("Encountered wrong enum case")
            return
        }
        
        expect(title) == "Error"
        expect(message) == "Could not create a request to send to the network"
        
        // Loading should have stopped:
        expect(self.sut.isLoading.value).to(beFalse())
    }
    
    func test_retryAfterNetworkError() async throws {
        // Arrange
        let query = "First query"
        let networkService = FetchCollectionServiceFakeSpy(loadResponse: nil) // `nil` means `throw`
        sut = OverviewViewModel(initialQuery: query, fetchCollectionService: networkService)

        // wait for it to load the first error:
        await expect(self.sut.errorAlerts.value).toEventuallyNot(beNil())
        let errorAlert = try XCTUnwrap(sut.errorAlerts.value)
        
        // Fish around for the `retryHandler`:
        guard case let .networkError(_, _, retryHandler) = errorAlert else {
            fail("Encountered wrong enum case")
            return
        }
        
        // Network is working again!
        networkService.loadResponse = [.stub1]
        
        // Act
        retryHandler()

        // Assert
        expect(self.sut.isLoading.value).to(beTrue())
        
        // wait for the load to complete
        await expect(networkService.invokedLoadCount).toEventually(equal(2)) // second attempt
        await expect(networkService.invokedLoadParameters).toEventually(equal((query, 1))) // loading first page
        
        // Check the output of the ViewModel is correct after network load:
        let expectedValue: (OverviewViewModel.StateChangeMode, [CollectionItem])? = (
            .overwrite, [CollectionItem.from(artObject: .stub1)]
        )
        await expect(self.sut.itemUpdates.value).toEventually(equal(expectedValue))
        
        // Loading should have stopped:
        expect(self.sut.isLoading.value).to(beFalse()) 
    }
}

// MARK: - Spies -

private class FetchCollectionServiceFakeSpy: FetchCollectionServiceType {
 
    /// If this is nil then `load()` will throw an error.
    var loadResponse: [Feature_OverviewScreen.CollectionResponse.ArtObject]?
    init(loadResponse: [Feature_OverviewScreen.CollectionResponse.ArtObject]?) {
        self.loadResponse = loadResponse
    }
    
    var invokedLoadCount: Int = 0
    var invokedLoadParameters: ((query: String?, page: Int))?
    
    func load(query: String?, page: Int) async throws -> [Feature_OverviewScreen.CollectionResponse.ArtObject] {
        invokedLoadCount += 1
        invokedLoadParameters = (query, page)
        
        guard let loadResponse = loadResponse else {
            throw Transport.Error.couldNotCreateRequest // for example
        }
        return loadResponse
    }
}

private class OverviewViewModelDelegateSpy: OverviewViewModelDelegate {

    var invokedUserWantsMoreInfoOnCount = 0
    var invokedUserWantsMoreInfoOnParameters: (objectNumber: String, Void)?

    func userWantsMoreInfoOn(objectNumber: String) {
        invokedUserWantsMoreInfoOnCount += 1
        invokedUserWantsMoreInfoOnParameters = (objectNumber, ())
    }
}

// MARK: - Fake data -

private extension Feature_OverviewScreen.CollectionResponse.ArtObject {
    
    static var stub1: Feature_OverviewScreen.CollectionResponse.ArtObject {
        .init(
            id: "abc",
            objectNumber: "abc",
            title: "title",
            principalOrFirstMaker: "principalOrFirstMaker",
            webImage: CollectionResponse.ArtObject.WebImage(url: "http://hello.com")
        )
    }
    
    static var stub2: Feature_OverviewScreen.CollectionResponse.ArtObject {
        .init(
            id: "def",
            objectNumber: "def",
            title: "title2",
            principalOrFirstMaker: "principalOrFirstMaker2",
            webImage: CollectionResponse.ArtObject.WebImage(url: "http://goodbye.com")
        )
    }
}

private extension CollectionItem {
    
    static func from(artObject: Feature_OverviewScreen.CollectionResponse.ArtObject) -> CollectionItem {
        CollectionItem(
            name: artObject.title!,
            section: Section(name: artObject.principalOrFirstMaker!),
            objectNumber: artObject.objectNumber,
            imageURL: URL(string: artObject.webImage!.url!)!
        )
    }
    
}

