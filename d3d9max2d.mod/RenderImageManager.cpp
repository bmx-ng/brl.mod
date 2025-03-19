
#include <cstdint>
#include <iostream>
#include <list>

//#define OUTPUT_DEBUG_INFO

struct BBOBJECT;
static std::list<BBOBJECT*> renderImages;
static std::list<BBOBJECT*>::iterator renderImagesIter;

void DebugOutput(const std::string& msg) {
	std::cout << msg << std::endl;
}
void DebugOutput(const std::string& msg, BBOBJECT* object) {
	std::cout << msg << " " << object << std::endl;
}
#if defined(OUTPUT_DEBUG_INFO)
#define DEBUG_OUTPUT DebugOutput
#else
#define DEBUG_OUTPUT
#endif

extern"C"
{
	void RenderImageManager_AddRenderImage(BBOBJECT* object) {
		DEBUG_OUTPUT("RenderImageManager_AddRenderTarget - Adding render image: ", object);
		renderImages.push_back(object);
		DEBUG_OUTPUT("RenderImageManager_AddRenderTarget - Render image list count: " + std::to_string(renderImages.size()));
	}
	
	void RenderImageManager_RemoveRenderImage(BBOBJECT* object) {
		DEBUG_OUTPUT("RenderImageManager_RemoveRenderTarget - Removing render image: ", object);
		//for(std::list<BBOBJECT*>::iterator it = renderImages.begin(); it != renderImages.end(); ++it) {
		//	if(*it == object) {
		//		DEBUG_OUTPUT("RenderImageManager_RemoveRenderTarget - Found: ", *it);
		//		renderImages.erase(it);
		//		break;
		//	}
		//}
		renderImages.remove(object);
		DEBUG_OUTPUT("RenderImageManager_RemoveRenderTarget - Render image list count: " + std::to_string(renderImages.size()));
	}
	
	void RenderImageManager_ResetIterator() {
		DEBUG_OUTPUT("RenderImageManager_ResetIterator - Render image list count: " + std::to_string(renderImages.size()));
		renderImagesIter = renderImages.begin();
	}
	
	bool RenderImageManager_GetNextValue(BBOBJECT** pObject) {
		if(renderImagesIter != renderImages.end()) {
			*pObject = *renderImagesIter;
			++renderImagesIter;
			return true;
		}
		return false;
	}
	
	
}
